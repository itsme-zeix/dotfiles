#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
shared_dir="$(cd -- "${SHARED_SKILLS_DIR:-$script_dir/../shared/skills}" && pwd -P)"
skills_dir="${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}/skills"

link_skill() {
	local source="$1"
	local target="$skills_dir/$2"

	if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
		return
	fi
	if [[ -e "$target" || -L "$target" ]]; then
		printf 'Refusing to overwrite: %s\n' "$target" >&2
		exit 1
	fi

	ln -s "$source" "$target"
	printf 'Linked %s -> %s\n' "$target" "$source"
}

mkdir -p "$skills_dir"
link_skill "$shared_dir" shared
for source in "$script_dir"/skills/*; do
	[[ -f "$source/SKILL.md" ]] || continue
	link_skill "$source" "$(basename -- "$source")"
done
