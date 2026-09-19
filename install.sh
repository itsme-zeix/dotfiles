#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
BACKUP_ROOT="${BACKUP_ROOT:-$HOME/.dotfiles-backup}"
DEFAULT_PACKAGES=(vim nvim pi agent-skills)
LINK_SOURCES=()
LINK_TARGETS=()

usage() {
  cat <<'EOF'
Usage: ./install.sh <command> [packages...]

Commands:
  dry-run   Preview links and backups without changing files
  link      Create links and fail when a target conflicts
  install   Back up conflicting targets, then create links
  unlink    Remove only links managed by this repository
  help      Show this help

Packages:
  vim           Vim configuration
  nvim          Neovim configuration
  pi            Durable Pi configuration
  agent-skills  Portable user-level agent skills

Defaults to: vim nvim pi agent-skills
EOF
}

add_link() {
  LINK_SOURCES+=("$1")
  LINK_TARGETS+=("$2")
}

register_package() {
  local package="$1"
  local source

  case "$package" in
    vim)
      add_link "$DOTFILES_DIR/vim/.vimrc" "$HOME/.vimrc"
      add_link "$DOTFILES_DIR/vim/.vim" "$HOME/.vim"
      ;;
    nvim)
      add_link "$DOTFILES_DIR/nvim/.stylua.toml" "$HOME/.config/nvim/.stylua.toml"
      add_link "$DOTFILES_DIR/nvim/init.lua" "$HOME/.config/nvim/init.lua"
      add_link "$DOTFILES_DIR/nvim/lazy-lock.json" "$HOME/.config/nvim/lazy-lock.json"
      add_link "$DOTFILES_DIR/nvim/lua" "$HOME/.config/nvim/lua"
      ;;
    pi)
      add_link "$DOTFILES_DIR/pi/AGENTS.md" "$HOME/.pi/agent/AGENTS.md"
      for source in "$DOTFILES_DIR"/pi/extensions/*.ts; do
        [[ -e "$source" ]] || continue
        add_link "$source" "$HOME/.pi/agent/extensions/$(basename "$source")"
      done
      for source in "$DOTFILES_DIR"/pi/prompts/*.md; do
        [[ -e "$source" ]] || continue
        add_link "$source" "$HOME/.pi/agent/prompts/$(basename "$source")"
      done
      for source in "$DOTFILES_DIR"/pi/skills/*/SKILL.md; do
        [[ -e "$source" ]] || continue
        add_link "$source" "$HOME/.pi/agent/skills/$(basename "$(dirname "$source")")/SKILL.md"
      done
      ;;
    agent-skills)
      for source in "$DOTFILES_DIR"/agent-skills/*; do
        [[ -d "$source" ]] || continue
        add_link "$source" "$HOME/.agents/skills/$(basename "$source")"
      done
      ;;
    *)
      printf 'Unknown package: %s\n' "$package" >&2
      exit 2
      ;;
  esac
}

canonical_path() {
  local path="$1"
  local parent
  parent="$(cd -P -- "$(dirname -- "$path")" 2>/dev/null && pwd)" || return 1
  printf '%s/%s\n' "$parent" "$(basename -- "$path")"
}

link_destination() {
  local target="$1"
  local destination
  destination="$(readlink "$target")"
  if [[ "$destination" != /* ]]; then
    destination="$(dirname -- "$target")/$destination"
  fi
  canonical_path "$destination"
}

is_managed_link() {
  local source="$1"
  local target="$2"
  local actual
  local expected
  [[ -L "$target" ]] || return 1
  actual="$(link_destination "$target")" || return 1
  expected="$(canonical_path "$source")" || return 1
  [[ "$actual" == "$expected" ]]
}

backup_path() {
  local target="$1"
  local stamp="$2"
  local relative="${target#"$HOME"/}"
  local destination="$BACKUP_ROOT/$stamp/$relative"

  mkdir -p -- "$(dirname -- "$destination")"
  mv -- "$target" "$destination"
  printf 'Backed up %s -> %s\n' "$target" "$destination"
}

create_link() {
  local source="$1"
  local target="$2"
  local command="$3"
  local stamp="$4"

  if [[ ! -e "$source" ]]; then
    printf 'Missing source: %s\n' "$source" >&2
    return 1
  fi

  if is_managed_link "$source" "$target"; then
    printf 'Already linked: %s\n' "$target"
    return
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    case "$command" in
      dry-run)
        printf 'Would back up: %s\n' "$target"
        ;;
      install)
        backup_path "$target" "$stamp"
        ;;
      link)
        printf 'Conflict: %s already exists\n' "$target" >&2
        return 1
        ;;
    esac
  fi

  if [[ "$command" == "dry-run" ]]; then
    printf 'Would link: %s -> %s\n' "$target" "$source"
    return
  fi

  mkdir -p -- "$(dirname -- "$target")"
  ln -s -- "$source" "$target"
  printf 'Linked %s -> %s\n' "$target" "$source"
}

remove_link() {
  local source="$1"
  local target="$2"

  if is_managed_link "$source" "$target"; then
    unlink -- "$target"
    printf 'Unlinked %s\n' "$target"
  elif [[ -e "$target" || -L "$target" ]]; then
    printf 'Left unmanaged target: %s\n' "$target"
  fi
}

main() {
  local command="${1:-help}"
  if [[ "$command" == "help" || "$command" == "-h" || "$command" == "--help" ]]; then
    usage
    return
  fi

  case "$command" in
    dry-run|link|install|unlink)
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift

  local packages=("$@")
  if [[ "${#packages[@]}" -eq 0 ]]; then
    packages=("${DEFAULT_PACKAGES[@]}")
  fi

  local package
  for package in "${packages[@]}"; do
    register_package "$package"
  done

  local stamp
  stamp="$(date +%Y%m%d-%H%M%S)-$$"
  local index
  for ((index = 0; index < ${#LINK_SOURCES[@]}; index++)); do
    if [[ "$command" == "unlink" ]]; then
      remove_link "${LINK_SOURCES[$index]}" "${LINK_TARGETS[$index]}"
    else
      create_link "${LINK_SOURCES[$index]}" "${LINK_TARGETS[$index]}" "$command" "$stamp"
    fi
  done
}

main "$@"
