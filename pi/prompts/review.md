---
description: Review changes for material bugs, regressions, and missing tests
argument-hint: "[base ref, commit, files, or focus]"
---
Review the current code changes. Optional target or focus: $ARGUMENTS

This is a read-only review. Do not edit files, apply fixes, commit, push, or post comments remotely.

## Establish the target

1. Read repository instructions first.
2. If the arguments identify a base ref, commit, or files, review that target. Otherwise review staged, unstaged, and untracked working-tree changes.
3. Inspect the diff before surrounding code. Then read only the context needed to understand the changed behavior and intended contract.
4. Separate problems introduced by the change from pre-existing issues. Report only introduced or directly exposed problems.

## Review passes

Launch exactly two read-only reviewer subagents in parallel with fresh context rather than forks. Explicitly assign the `adversarial-review` skill to both and give them the same target and task. Require each to inspect the repository directly. Do not share either reviewer's conclusions with the other.

Treat the reviews as independent candidate-generation passes, not votes: agreement raises confidence but is not required, and disagreement requires direct validation. The parent must validate every candidate against the actual diff, surrounding code, and tests, then deduplicate overlapping findings. If subagents or the skill are unavailable, disclose the fallback and apply the same review contract in the parent session.

## Output

Report findings first, ordered by severity. Each finding must include:

- severity and a concise title;
- an exact file and line reference;
- the concrete user or system impact;
- the specific changed behavior that causes it;
- a minimal direction for remediation, without implementing it.

Then list open questions or assumptions and verification gaps. Keep the change summary brief and secondary. If there are no material findings, say so explicitly.
