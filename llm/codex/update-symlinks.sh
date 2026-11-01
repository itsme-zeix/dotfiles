#!/usr/bin/env bash
set -euo pipefail

script_dir="$(dirname -- "${BASH_SOURCE[0]}")"
shared_dir="$(cd -- "${SHARED_DIR:-$script_dir/../shared}" && pwd -P)"
codex_dir="${CODEX_HOME:-$HOME/.codex}"
status=0

link() {
	local source="$1" target="$2"
	if [[ -L "$target" && "$target" -ef "$source" ]]; then
		return
	fi
	if [[ -e "$target" || -L "$target" ]]; then
		printf 'Refusing to overwrite: %s\n' "$target" >&2
		status=1
		return
	fi
	mkdir -p "$(dirname -- "$target")"
	ln -s "$source" "$target"
	printf 'Linked %s -> %s\n' "$target" "$source"
}

link "$shared_dir/AGENTS.md" "$codex_dir/AGENTS.md"
link "$shared_dir/skills" "$codex_dir/skills/shared"

exit "$status"
