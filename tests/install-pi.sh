#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

export HOME="$TEST_ROOT/home"
export BACKUP_ROOT="$TEST_ROOT/backups"
mkdir -p "$HOME/.pi/agent" "$HOME/.config/nvim"
printf 'old agents\n' > "$HOME/.pi/agent/AGENTS.md"
printf 'old nvim\n' > "$HOME/.config/nvim/init.lua"
printf 'keep runtime local\n' > "$HOME/.pi/agent/settings.json"

"$ROOT/install.sh" dry-run >/dev/null
[[ "$(cat "$HOME/.pi/agent/AGENTS.md")" == "old agents" ]]
[[ "$(cat "$HOME/.config/nvim/init.lua")" == "old nvim" ]]

"$ROOT/install.sh" install >/dev/null

diff -u \
  <(printf '%s\n' \
    .agents/skills/technical-writing \
    .config/nvim/.stylua.toml \
    .config/nvim/init.lua \
    .config/nvim/lazy-lock.json \
    .config/nvim/lua \
    .pi/agent/AGENTS.md \
    .pi/agent/extensions/mutation-stats.ts \
    .pi/agent/extensions/project-status.ts \
    .pi/agent/extensions/turn-timer.ts \
    .pi/agent/extensions/workflow.ts \
    .pi/agent/prompts/devils-advocate.md \
    .pi/agent/prompts/pattern-scout.md \
    .pi/agent/prompts/review-and-simplify.md \
    .pi/agent/prompts/review.md \
    .pi/agent/prompts/simplify.md \
    .pi/agent/skills/adversarial-review/SKILL.md \
    .pi/agent/skills/ketch-research/SKILL.md \
    .pi/agent/skills/local-simplifier/SKILL.md \
    .pi/agent/skills/pattern-scout/SKILL.md \
    .vim \
    .vimrc) \
  <(find "$HOME" -type l -print | sed "s|$HOME/||" | sort)

[[ "$(cat "$HOME/.pi/agent/settings.json")" == "keep runtime local" ]]
[[ "$(find "$BACKUP_ROOT" -path '*/.pi/agent/AGENTS.md' -exec cat {} \;)" == "old agents" ]]
[[ "$(find "$BACKUP_ROOT" -path '*/.config/nvim/init.lua' -exec cat {} \;)" == "old nvim" ]]

"$ROOT/install.sh" link >/dev/null
"$ROOT/install.sh" unlink >/dev/null

[[ "$(cat "$HOME/.pi/agent/settings.json")" == "keep runtime local" ]]
if find "$HOME" -type l -print -quit | grep -q .; then
  printf 'managed links remain after unlink\n' >&2
  exit 1
fi

broken_skill="$HOME/.agents/skills/technical-writing"
ln -s "$TEST_ROOT/missing-skill" "$broken_skill"
if "$ROOT/install.sh" link agent-skills >/dev/null 2>&1; then
  printf 'link unexpectedly replaced an unrelated broken symlink\n' >&2
  exit 1
fi
[[ "$(readlink "$broken_skill")" == "$TEST_ROOT/missing-skill" ]]
unlink "$broken_skill"

printf 'unmanaged\n' > "$HOME/.pi/agent/AGENTS.md"
if "$ROOT/install.sh" link pi >/dev/null 2>&1; then
  printf 'link unexpectedly replaced an unmanaged target\n' >&2
  exit 1
fi
[[ "$(cat "$HOME/.pi/agent/AGENTS.md")" == "unmanaged" ]]

printf 'Dotfiles install fixture passed\n'
