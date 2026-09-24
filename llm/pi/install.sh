#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
DOTFILES_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd -P)"
PI_AGENT_DIR="${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}"
PI_PACKAGE_DIR="$(npm root -g)/@earendil-works/pi-coding-agent"
PI_VERSION="0.85.1"
SUBAGENTS_PACKAGE_DIR="$PI_AGENT_DIR/npm/node_modules/pi-subagents"
SUBAGENTS_VERSION="0.48.0"
LINK_SOURCES=()
LINK_TARGETS=()
LEGACY_SOURCES=()
LEGACY_TARGETS=()

add_link() {
	LINK_SOURCES+=("$1")
	LINK_TARGETS+=("$2")
}

add_legacy_link() {
	LEGACY_SOURCES+=("$1")
	LEGACY_TARGETS+=("$2")
}

canonical_path() {
	local parent="$(dirname -- "$1")"
	local suffix="$(basename -- "$1")"
	while [[ ! -d "$parent" ]]; do
		suffix="$(basename -- "$parent")/$suffix"
		parent="$(dirname -- "$parent")"
	done
	parent="$(cd -P -- "$parent" && pwd)"
	printf '%s/%s\n' "$parent" "$suffix"
}

is_link_to() {
	local source="$1"
	local target="$2"
	local destination
	[[ -L "$target" ]] || return 1
	destination="$(readlink "$target")"
	if [[ "$destination" != /* ]]; then
		destination="$(dirname -- "$target")/$destination"
	fi
	[[ "$(canonical_path "$destination")" == "$(canonical_path "$source")" ]]
}

is_legacy_link() {
	local target="$1"
	local index
	for ((index = 0; index < ${#LEGACY_SOURCES[@]}; index++)); do
		if [[ "${LEGACY_TARGETS[$index]}" == "$target" ]] &&
			is_link_to "${LEGACY_SOURCES[$index]}" "$target"; then
			return 0
		fi
	done
	return 1
}

is_legacy_skill_dir() {
	local target="$1"
	[[ -d "$target" && ! -L "$target" ]] || return 1
	[[ "$(ls -A "$target")" == "SKILL.md" ]] || return 1
	is_legacy_link "$target/SKILL.md"
}

register_links() {
	local source
	local name
	add_link "$DOTFILES_DIR/llm/shared/AGENTS.md" "$PI_AGENT_DIR/AGENTS.md"
	add_legacy_link "$DOTFILES_DIR/pi/AGENTS.md" "$PI_AGENT_DIR/AGENTS.md"
	for source in "$SCRIPT_DIR"/extensions/*.ts; do
		[[ -e "$source" ]] || continue
		name="$(basename -- "$source")"
		add_link "$source" "$PI_AGENT_DIR/extensions/$name"
		add_legacy_link "$DOTFILES_DIR/pi/extensions/$name" "$PI_AGENT_DIR/extensions/$name"
	done
	for name in review review-and-simplify simplify pattern-scout devils-advocate; do
		add_legacy_link "$DOTFILES_DIR/pi/prompts/$name.md" "$PI_AGENT_DIR/prompts/$name.md"
	done
	for name in adversarial-review ketch-research local-simplifier pattern-scout; do
		add_legacy_link "$DOTFILES_DIR/pi/skills/$name/SKILL.md" "$PI_AGENT_DIR/skills/$name/SKILL.md"
	done
	for source in "$DOTFILES_DIR"/llm/shared/skills/*; do
		[[ -d "$source" ]] || continue
		name="$(basename -- "$source")"
		add_link "$source" "$PI_AGENT_DIR/skills/$name"
	done
}

preflight_links() {
	local index
	local source
	local target
	for ((index = 0; index < ${#LINK_SOURCES[@]}; index++)); do
		source="${LINK_SOURCES[$index]}"
		target="${LINK_TARGETS[$index]}"
		[[ -e "$source" ]] || { printf 'Missing source: %s\n' "$source" >&2; exit 1; }
		if is_link_to "$source" "$target" || is_legacy_link "$target" || is_legacy_skill_dir "$target"; then
			continue
		fi
		if [[ -e "$target" || -L "$target" ]]; then
			printf 'Conflicting Pi file: %s\n' "$target" >&2
			exit 1
		fi
	done
}

install_links() {
	local index
	local source
	local target
	for ((index = 0; index < ${#LEGACY_SOURCES[@]}; index++)); do
		source="${LEGACY_SOURCES[$index]}"
		target="${LEGACY_TARGETS[$index]}"
		if is_link_to "$source" "$target"; then
			unlink "$target"
			printf 'Removed old link: %s\n' "$target"
		fi
	done
	for ((index = 0; index < ${#LINK_SOURCES[@]}; index++)); do
		source="${LINK_SOURCES[$index]}"
		target="${LINK_TARGETS[$index]}"
		if is_link_to "$source" "$target"; then
			continue
		fi
		if [[ -d "$target" && ! -L "$target" ]]; then
			rmdir "$target"
		fi
		mkdir -p "$(dirname -- "$target")"
		ln -s "$source" "$target"
		printf 'Linked %s -> %s\n' "$target" "$source"
	done
}

assert_package_version() {
	local label="$1"
	local package_dir="$2"
	local expected="$3"
	local actual
	actual="$(node -e 'process.stdout.write(require(process.argv[1]).version)' "$package_dir/package.json")"
	if [[ "$actual" != "$expected" ]]; then
		printf 'expected %s %s, found %s; refusing to apply patches\n' "$label" "$expected" "$actual" >&2
		exit 1
	fi
}

apply_tracked_patch() {
	local label="$1"
	local target_dir="$2"
	local patch_file="$3"
	if patch --batch --forward --dry-run -p1 -d "$target_dir" < "$patch_file" >/dev/null 2>&1; then
		patch --batch --forward -p1 -d "$target_dir" < "$patch_file"
	elif patch --batch --forward --dry-run -R -p1 -d "$target_dir" < "$patch_file" >/dev/null 2>&1; then
		printf '%s already patched\n' "$label"
	else
		printf '%s no longer matches its tracked patch\n' "$label" >&2
		exit 1
	fi
}

register_links
preflight_links

# A bundle containing 'to send now' is the source-patched build an earlier
# version of this script installed; replace it with the stock release.
if [[ -f "$PI_PACKAGE_DIR/package.json" ]] && ! grep -rFq 'to send now' "$PI_PACKAGE_DIR/dist/bundle" 2>/dev/null; then
	assert_package_version Pi "$PI_PACKAGE_DIR" "$PI_VERSION"
else
	npm install -g --ignore-scripts "@earendil-works/pi-coding-agent@$PI_VERSION"
	assert_package_version Pi "$PI_PACKAGE_DIR" "$PI_VERSION"
fi

if ! command -v pi >/dev/null 2>&1; then
	printf 'pi is not on PATH\n' >&2
	exit 1
fi

if ! command -v ketch >/dev/null 2>&1; then
	if command -v brew >/dev/null 2>&1; then
		brew install ketch
	elif command -v npm >/dev/null 2>&1; then
		npm install -g ketch-cli
	fi
fi

if command -v ketch >/dev/null 2>&1; then
	ketch_config_path="$(ketch config path)"
	if [[ ! -f "$ketch_config_path" ]]; then
		ketch config set backend ddg
	fi
else
	printf 'ketch not found; skipping research CLI setup\n' >&2
fi

pi install npm:pi-subagents@0.48.0
pi install npm:pi-mono-btw@1.7.4

assert_package_version pi-subagents "$SUBAGENTS_PACKAGE_DIR" "$SUBAGENTS_VERSION"
apply_tracked_patch "pi-subagents static step indicators" "$SUBAGENTS_PACKAGE_DIR" "$SCRIPT_DIR/patches/pi-subagents-static-steps.patch"

install_links
