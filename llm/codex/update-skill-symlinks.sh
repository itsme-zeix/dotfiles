#!/usr/bin/env bash
set -euo pipefail

script_dir="$(dirname -- "${BASH_SOURCE[0]}")"
source_dir="$(cd -- "${SHARED_SKILLS_DIR:-$script_dir/../shared/skills}" && pwd -P)"
codex_dir="${CODEX_ROOT_DIR:-${CODEX_HOME:-$HOME/.codex}}"
target="$codex_dir/skills/shared"

if [[ -L "$target" && "$(readlink "$target")" == "$source_dir" ]]; then
	printf 'Shared skill link is up to date.\n'
	exit 0
fi

if [[ -e "$target" || -L "$target" ]]; then
	printf 'Refusing to overwrite: %s\n' "$target" >&2
	exit 1
fi

mkdir -p "$codex_dir/skills"
ln -s "$source_dir" "$target"
printf 'Linked %s -> %s\n' "$target" "$source_dir"
