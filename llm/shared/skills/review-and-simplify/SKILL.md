---
name: review-and-simplify
description: Reviews changes for bugs and suggests simplifications and cleaner patterns in one run, without editing files.
disable-model-invocation: true
---

# Review and simplify

Run a review, a simplify pass, and a pattern scout on the same target in one go. Pick the target the way `../review/SKILL.md` does, and use any focus given with the command. Don't edit files, commit, push, or post comments.

## Hand off

Launch four fresh, read-only subagents (not forks of this conversation). Give each the exact target and the goal of the change if you know it:

- Two independent reviewers, each with the Criteria section of `../review/SKILL.md`.
- One simplifier, with the Criteria section of `../simplify-changes/SKILL.md`.
- One pattern scout, with the Criteria section of `../pattern-scout/SKILL.md`. Tell it to skip simplifications inside the changed code, since the simplifier covers those.

Ask each for findings with file and line. Don't share findings between them. If subagents aren't available, do the passes yourself and say so.

## Report

Check every finding against the diff, code, and tests, and merge duplicates. Don't apply anything.

List bugs first, most severe first, with file and line, what goes wrong, the cause, and the smallest fix. Then list worthwhile simplifications and patterns with their benefit and tradeoff. Say when a simplification would also fix, or conflict with, a bug. Mention any notable suggestion you dropped or couldn't check. If there's nothing worth reporting, say so.
