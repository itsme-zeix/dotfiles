#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
shared_dir="$(cd -- "${SHARED_DIR:-$script_dir/../shared}" && pwd -P)"
pi_dir="${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}"
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

link "$shared_dir/AGENTS.md" "$pi_dir/AGENTS.md"
link "$shared_dir/skills" "$pi_dir/skills/shared"
for source in "$script_dir"/skills/*/; do
	source="${source%/}"
	link "$source" "$pi_dir/skills/$(basename -- "$source")"
done

exit "$status"
