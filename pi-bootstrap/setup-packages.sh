#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BTW_PACKAGE_DIR="$HOME/.pi/agent/npm/node_modules/pi-btw"
BTW_PATCH_FILE="$SCRIPT_DIR/patches/pi-btw-side.patch"
SUBAGENTS_PACKAGE_DIR="$HOME/.pi/agent/npm/node_modules/pi-subagents"
SUBAGENTS_PATCH_FILE="$SCRIPT_DIR/patches/pi-subagents-static-steps.patch"
SUBAGENTS_VERSION="0.48.0"
PI_PACKAGE_DIR="$(npm root -g)/@earendil-works/pi-coding-agent"
PI_PATCH_FILE="$SCRIPT_DIR/patches/pi-abort-message.patch"
PI_TITLE_PATCH_FILE="$SCRIPT_DIR/patches/pi-extension-title.patch"
PI_VERSION="0.84.1"

if ! command -v ketch >/dev/null 2>&1; then
	brew install 1broseidon/tap/ketch
fi

ketch_config_path="$(ketch config path)"
if [[ ! -f "$ketch_config_path" ]]; then
	ketch config set backend ddg
fi

pi install npm:pi-subagents@0.48.0
pi install npm:pi-mono-btw@1.7.4
pi install npm:pi-sandbox@0.6.1
pi install npm:pi-btw@0.4.1

installed_subagents_version="$(node -e 'process.stdout.write(require(process.argv[1]).version)' "$SUBAGENTS_PACKAGE_DIR/package.json")"
if [[ "$installed_subagents_version" != "$SUBAGENTS_VERSION" ]]; then
	printf 'expected pi-subagents %s, found %s; refusing to apply UI patch\n' "$SUBAGENTS_VERSION" "$installed_subagents_version" >&2
	exit 1
fi

if patch --batch --forward --dry-run -p1 -d "$SUBAGENTS_PACKAGE_DIR" < "$SUBAGENTS_PATCH_FILE" >/dev/null 2>&1; then
	patch --batch --forward -p1 -d "$SUBAGENTS_PACKAGE_DIR" < "$SUBAGENTS_PATCH_FILE"
elif patch --batch --forward --dry-run -R -p1 -d "$SUBAGENTS_PACKAGE_DIR" < "$SUBAGENTS_PATCH_FILE" >/dev/null 2>&1; then
	printf 'pi-subagents static step indicators already patched\n'
else
	printf 'pi-subagents no longer matches the static step indicator patch\n' >&2
	exit 1
fi

if patch --batch --forward --dry-run -p1 -d "$BTW_PACKAGE_DIR" < "$BTW_PATCH_FILE" >/dev/null 2>&1; then
	patch --batch --forward -p1 -d "$BTW_PACKAGE_DIR" < "$BTW_PATCH_FILE"
elif patch --batch --forward --dry-run -R -p1 -d "$BTW_PACKAGE_DIR" < "$BTW_PATCH_FILE" >/dev/null 2>&1; then
	printf 'pi-btw command aliases already patched\n'
else
	printf 'pi-btw no longer matches the pinned command patch\n' >&2
	exit 1
fi

installed_pi_version="$(node -e 'process.stdout.write(require(process.argv[1]).version)' "$PI_PACKAGE_DIR/package.json")"
if [[ "$installed_pi_version" != "$PI_VERSION" ]]; then
	printf 'expected Pi %s, found %s; refusing to apply core patch\n' "$PI_VERSION" "$installed_pi_version" >&2
	exit 1
fi

if patch --batch --forward --dry-run -p1 -d "$PI_PACKAGE_DIR" < "$PI_PATCH_FILE" >/dev/null 2>&1; then
	patch --batch --forward -p1 -d "$PI_PACKAGE_DIR" < "$PI_PATCH_FILE"
elif patch --batch --forward --dry-run -R -p1 -d "$PI_PACKAGE_DIR" < "$PI_PATCH_FILE" >/dev/null 2>&1; then
	printf 'Pi abort message handling already patched\n'
else
	printf 'Pi no longer matches the abort message patch\n' >&2
	exit 1
fi

if patch --batch --forward --dry-run -p1 -d "$PI_PACKAGE_DIR" < "$PI_TITLE_PATCH_FILE" >/dev/null 2>&1; then
	patch --batch --forward -p1 -d "$PI_PACKAGE_DIR" < "$PI_TITLE_PATCH_FILE"
elif patch --batch --forward --dry-run -R -p1 -d "$PI_PACKAGE_DIR" < "$PI_TITLE_PATCH_FILE" >/dev/null 2>&1; then
	printf 'Pi extension title lifecycle already patched\n'
else
	printf 'Pi no longer matches the extension title lifecycle patch\n' >&2
	exit 1
fi
