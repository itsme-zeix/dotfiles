---
description: Parallel review and simplification recommendations
argument-hint: "[focus]"
---
Review the current working-tree changes and recommend simplifications. Optional focus: $ARGUMENTS

This workflow is read-only. Do not edit files, apply fixes, commit, push, or post comments remotely.

## Establish the target

1. Read repository instructions first.
2. Inspect staged, unstaged, and untracked changes, then read only the surrounding code and tests needed to understand the intended behavior.
3. Separate problems introduced by the changes from pre-existing issues. Keep all recommendations within the current change scope.

## Independent passes

Launch exactly four read-only subagents in parallel, each with fresh context rather than a fork of the current conversation. Require each to inspect the repository directly and return advisory results without editing.

- Assign reviewers one and two the `adversarial-review` skill and the same target and task. Do not share their conclusions with each other.
- Assign reviewer three the `local-simplifier` skill.
- Assign reviewer four both the `pattern-scout` and `ketch-research` skills. Do not share reviewer three's conclusions with reviewer four, or vice versa, before both finish.

If subagents or skills are unavailable, disclose the fallback and apply the corresponding skill contracts in the parent session.

## Reconcile

1. Validate every candidate against the diff, surrounding code, and tests. Deduplicate overlaps; agreement raises confidence but is not required.
2. Separate correctness findings from behavior-preserving simplification and pattern recommendations. Identify dependencies or conflicts between recommendations.
3. Do not apply any recommendation. Present the reconciled candidates so the user can decide what to implement.

## Output

Report correctness findings first by severity with exact file and line references, concrete impact, cause, and minimal remediation direction. Then report worthwhile simplification and pattern recommendations, including their expected benefit, tradeoffs, and any dependency on fixing a correctness issue first. List rejected or unverified suggestions separately and explain why they were excluded. If there are no material findings or worthwhile recommendations, say so explicitly.
