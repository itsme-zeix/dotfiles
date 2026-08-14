#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_ROOT="${BACKUP_ROOT:-$HOME/.dotfiles-backup}"
DEFAULT_PACKAGES=(vim nvim pi)
PI_MANAGED_PATHS=(
  AGENTS.md
  extensions/project-status.ts
  extensions/mutation-stats.ts
  extensions/turn-timer.ts
  extensions/workflow.ts
  skills/adversarial-review/SKILL.md
  skills/ketch-research/SKILL.md
  skills/local-simplifier/SKILL.md
  skills/pattern-scout/SKILL.md
  prompts/devils-advocate.md
  prompts/pattern-scout.md
  prompts/review.md
  prompts/review-and-simplify.md
  prompts/simplify.md
)

usage() {
  cat <<'EOF'
Usage: ./install.sh <command> [packages...]

Commands:
  dry-run   Show first-install backups and validate stow plans
  link      Link packages with stow, failing on conflicts
  install   Back up existing live config paths, then link packages
  restow    Re-run stow for already linked packages
  unstow    Remove symlinks managed by stow
  help      Show this help

Packages:
  vim       Links into $HOME
  nvim      Links into $HOME/.config/nvim
  pi        Links durable config into $HOME/.pi/agent

Defaults to: vim nvim pi
EOF
}

require_stow() {
  if command -v stow >/dev/null 2>&1; then
    return
  fi

  cat >&2 <<'EOF'
GNU Stow is not installed.

Install it with one of:
  brew install stow
  sudo apt install stow
  sudo dnf install stow
  sudo pacman -S stow
EOF
  exit 1
}

target_for_package() {
  case "$1" in
    vim)
      printf '%s\n' "$HOME"
      ;;
    nvim)
      printf '%s\n' "$HOME/.config/nvim"
      ;;
    pi)
      printf '%s\n' "$HOME/.pi/agent"
      ;;
    *)
      printf 'Unknown package: %s\n' "$1" >&2
      exit 2
      ;;
  esac
}

ensure_target_for_package() {
  case "$1" in
    vim)
      ;;
    nvim)
      mkdir -p "$HOME/.config/nvim"
      ;;
    pi)
      mkdir -p "$HOME/.pi/agent"
      ;;
  esac
}

run_stow() {
  local command="$1"
  local package="$2"
  local target
  target="$(target_for_package "$package")"

  local args=(
    --dir="$DOTFILES_DIR"
    --target="$target"
    --no-folding
  )

  case "$command" in
    dry-run)
      args+=(--simulate --verbose=2)
      ;;
    link)
      ;;
    restow)
      args+=(--restow)
      ;;
    unstow)
      args+=(--delete)
      ;;
    *)
      printf 'Unknown stow command: %s\n' "$command" >&2
      exit 2
      ;;
  esac

  stow "${args[@]}" "$package"
}

run_stow_plan() {
  local package="$1"
  local target
  target="$(target_for_package "$package")"

  local tmp_target
  local output
  tmp_target="$(mktemp -d)"

  if ! output="$(
    stow \
      --dir="$DOTFILES_DIR" \
      --target="$tmp_target" \
      --simulate \
      --no-folding \
      "$package" 2>&1
  )"; then
    printf '%s\n' "$output" >&2
    rm -rf "$tmp_target"
    return 1
  fi

  rm -rf "$tmp_target"
  printf 'Stow plan OK: %s -> %s\n' "$package" "$target"
}

show_backup_path() {
  local path="$1"

  if [[ -e "$path" || -L "$path" ]]; then
    printf 'Would back up: %s\n' "$path"
  else
    printf 'No existing path: %s\n' "$path"
  fi
}

show_backup_plan() {
  local package="$1"

  case "$package" in
    vim)
      show_backup_path "$HOME/.vimrc"
      show_backup_path "$HOME/.vim"
      ;;
    nvim)
      show_backup_path "$HOME/.config/nvim"
      ;;
    pi)
      local path
      for path in "${PI_MANAGED_PATHS[@]}"; do
        show_backup_path "$HOME/.pi/agent/$path"
      done
      ;;
  esac
}

backup_path() {
  local path="$1"
  local stamp="$2"

  if [[ ! -e "$path" && ! -L "$path" ]]; then
    return
  fi

  local rel="${path#$HOME/}"
  local dest="$BACKUP_ROOT/$stamp/$rel"
  mkdir -p "$(dirname "$dest")"
  mv "$path" "$dest"
  printf 'Backed up %s -> %s\n' "$path" "$dest"
}

backup_package() {
  local package="$1"
  local stamp="$2"

  case "$package" in
    vim)
      backup_path "$HOME/.vimrc" "$stamp"
      backup_path "$HOME/.vim" "$stamp"
      ;;
    nvim)
      backup_path "$HOME/.config/nvim" "$stamp"
      ;;
    pi)
      local path
      for path in "${PI_MANAGED_PATHS[@]}"; do
        backup_path "$HOME/.pi/agent/$path" "$stamp"
      done
      ;;
  esac
}

install_package() {
  local package="$1"
  local stamp="$2"

  run_stow unstow "$package" >/dev/null 2>&1 || true
  backup_package "$package" "$stamp"
  ensure_target_for_package "$package"
  run_stow link "$package"
}

main() {
  local command="${1:-help}"
  if [[ "$command" == "help" || "$command" == "-h" || "$command" == "--help" ]]; then
    usage
    return
  fi
  shift || true

  local packages=("$@")
  if [[ "${#packages[@]}" -eq 0 ]]; then
    packages=("${DEFAULT_PACKAGES[@]}")
  fi

  require_stow
  cd "$DOTFILES_DIR"

  case "$command" in
    dry-run)
      local package
      for package in "${packages[@]}"; do
        show_backup_plan "$package"
        run_stow_plan "$package"
      done
      ;;
    link|restow|unstow)
      local package
      for package in "${packages[@]}"; do
        ensure_target_for_package "$package"
        run_stow "$command" "$package"
      done
      ;;
    install)
      local stamp
      stamp="$(date +%Y%m%d-%H%M%S)"
      local package
      for package in "${packages[@]}"; do
        install_package "$package" "$stamp"
      done
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
}

main "$@"
