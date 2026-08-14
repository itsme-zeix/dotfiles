#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

export HOME="$TEST_ROOT/home"
export BACKUP_ROOT="$TEST_ROOT/backups"
mkdir -p "$HOME/.pi/agent"
printf 'old agents\n' > "$HOME/.pi/agent/AGENTS.md"
printf 'keep bootstrap local\n' > "$HOME/.pi/agent/setup-packages.sh"

"$ROOT/install.sh" install pi >/dev/null

cat > "$TEST_ROOT/expected" <<'EOF'
AGENTS.md
extensions/mutation-stats.ts
extensions/project-status.ts
extensions/turn-timer.ts
extensions/workflow.ts
prompts/devils-advocate.md
prompts/pattern-scout.md
prompts/review-and-simplify.md
prompts/review.md
prompts/simplify.md
skills/adversarial-review/SKILL.md
skills/ketch-research/SKILL.md
skills/local-simplifier/SKILL.md
skills/pattern-scout/SKILL.md
EOF

find "$HOME/.pi/agent" -type l -print \
  | sed "s|$HOME/.pi/agent/||" \
  | sort > "$TEST_ROOT/actual"

diff -u "$TEST_ROOT/expected" "$TEST_ROOT/actual"

[[ "$(cat "$HOME/.pi/agent/setup-packages.sh")" == "keep bootstrap local" ]]
[[ "$(find "$BACKUP_ROOT" -path '*/.pi/agent/AGENTS.md' -exec cat {} \;)" == "old agents" ]]

printf 'Pi install fixture passed\n'
