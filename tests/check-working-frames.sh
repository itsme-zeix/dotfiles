#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
PI_AGENT_DIR="${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}"
TIMER_FILE="$ROOT/pi/extensions/turn-timer.ts"
PATCH_FILE="$ROOT/pi/patches/pi-subagents-static-steps.patch"
INSTALLED_FILE="$PI_AGENT_DIR/npm/node_modules/pi-subagents/src/tui/render.ts"

extract_frames() {
	local name="$1" file="$2"
	grep "${name} = \\[" "$file" | tail -1 | grep -o '\[[^]]*\]' | tr -d '[]", ' || true
}

fail_mismatch() {
	local label="$1" expected="$2" actual="$3"
	printf 'working frames out of sync: %s\n  turn-timer: %s\n  other:      %s\n' \
		"$label" "$expected" "$actual" >&2
	exit 1
}

timer_frames="$(extract_frames WORKING_FRAMES "$TIMER_FILE")"
[[ -n "$timer_frames" ]] || {
	printf 'could not read WORKING_FRAMES from %s\n' "$TIMER_FILE" >&2
	exit 1
}

patch_frames="$(extract_frames RUNNING_FRAMES "$PATCH_FILE")"
[[ -n "$patch_frames" ]] || {
	printf 'could not read RUNNING_FRAMES from %s\n' "$PATCH_FILE" >&2
	exit 1
}

[[ "$patch_frames" == "$timer_frames" ]] || fail_mismatch "pi-subagents patch vs turn-timer" "$timer_frames" "$patch_frames"

if [[ -f "$INSTALLED_FILE" ]]; then
	installed_frames="$(extract_frames RUNNING_FRAMES "$INSTALLED_FILE")"
	[[ -n "$installed_frames" ]] || {
		printf 'could not read RUNNING_FRAMES from %s\n' "$INSTALLED_FILE" >&2
		exit 1
	}
	[[ "$installed_frames" == "$timer_frames" ]] || fail_mismatch "installed pi-subagents vs turn-timer" "$timer_frames" "$installed_frames"
fi

printf 'working frames in sync: %s\n' "$timer_frames"
