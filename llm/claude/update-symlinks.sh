#!/usr/bin/env bash
set -euo pipefail

script_dir="$(dirname -- "${BASH_SOURCE[0]}")"
shared_dir="$(cd -- "${SHARED_DIR:-$script_dir/../shared}" && pwd -P)"
claude_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
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

link "$shared_dir/AGENTS.md" "$claude_dir/CLAUDE.md"

# Claude Code only finds skills one folder deep, so each skill gets its own link.
for source in "$shared_dir"/skills/*/; do
	source="${source%/}"
	link "$source" "$claude_dir/skills/$(basename -- "$source")"
done

# Remove links left behind by shared skills that were renamed or deleted.
for target in "$claude_dir"/skills/*; do
	if [[ -L "$target" && ! -e "$target" && "$(dirname -- "$(readlink "$target")")" -ef "$shared_dir/skills" ]]; then
		rm "$target"
		printf 'Removed stale link: %s\n' "$target"
	fi
done

exit "$status"
