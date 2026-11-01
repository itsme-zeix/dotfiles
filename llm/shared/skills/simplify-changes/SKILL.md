---
name: simplify-changes
description: Simplifies the current code changes without changing behavior, staying within the changed code.
disable-model-invocation: true
---

# Simplify

Simplify the working-tree changes (`git diff HEAD` plus the untracked files `git status` lists), using any focus given with the command.

## Hand off

Launch one fresh, read-only subagent (not a fork of this conversation) to find simplifications. Give it the changes, the relevant files, and the Criteria section below. Ask it to return each suggestion with file and line, what it simplifies, and why behavior stays the same. If subagents aren't available, do it yourself and say so.

## Criteria

Look for these in the changed code:

- An existing helper that would remove duplicated code.
- Control flow that could be clearer.
- Abstractions, options, or layers the change doesn't need.
- Fragile special cases.

Touch comments or test helpers only when they make the change hard to follow. Skip cosmetic churn and generalizing for the future. Finding nothing is a valid result.

## Apply

Check each suggestion against the code and tests, and apply only the ones that keep behavior the same. Edit only the changed code. Touch other code only when a simplification needs a matching change there, such as a caller. Then run the narrowest tests or checks that cover what you edited, and look over the final diff for accidental changes.

Report what changed, what checks ran, and any suggestion you skipped because it wasn't worth it. If nothing was worth simplifying, leave the code alone and say so.
