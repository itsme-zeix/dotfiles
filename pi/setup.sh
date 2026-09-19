#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PI_AGENT_DIR="${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}"
SUBAGENTS_PACKAGE_DIR="$PI_AGENT_DIR/npm/node_modules/pi-subagents"
SUBAGENTS_PATCH_FILE="$SCRIPT_DIR/patches/pi-subagents-static-steps.patch"
SUBAGENTS_VERSION="0.48.0"
PI_PACKAGE_DIR="$(npm root -g)/@earendil-works/pi-coding-agent"
PI_PATCH_FILE="$SCRIPT_DIR/patches/pi-abort-message.patch"
PI_TITLE_PATCH_FILE="$SCRIPT_DIR/patches/pi-extension-title.patch"
PI_INTERRUPT_PATCH_FILE="$SCRIPT_DIR/patches/pi-escape-send-queued.patch"
PI_VERSION="0.85.1"

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

if ! command -v ketch >/dev/null 2>&1; then
	brew install 1broseidon/tap/ketch
fi

ketch_config_path="$(ketch config path)"
if [[ ! -f "$ketch_config_path" ]]; then
	ketch config set backend ddg
fi

pi install npm:pi-subagents@0.48.0
pi install npm:pi-mono-btw@1.7.4

assert_package_version pi-subagents "$SUBAGENTS_PACKAGE_DIR" "$SUBAGENTS_VERSION"
apply_tracked_patch "pi-subagents static step indicators" "$SUBAGENTS_PACKAGE_DIR" "$SUBAGENTS_PATCH_FILE"

assert_package_version Pi "$PI_PACKAGE_DIR" "$PI_VERSION"
apply_tracked_patch "Pi abort message handling" "$PI_PACKAGE_DIR" "$PI_PATCH_FILE"
apply_tracked_patch "Pi extension title lifecycle" "$PI_PACKAGE_DIR" "$PI_TITLE_PATCH_FILE"
apply_tracked_patch "Pi Escape sends queued messages" "$PI_PACKAGE_DIR" "$PI_INTERRUPT_PATCH_FILE"
