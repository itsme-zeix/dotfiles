---
description: Simplify recent changes while preserving behavior
argument-hint: "[focus]"
---
Review and simplify the current code changes while preserving intended behavior. Optional focus: $ARGUMENTS

1. Inspect the current diff and repository instructions to establish the target. Restrict edits to files already changed unless a directly required adjustment cannot be made otherwise.
2. Launch exactly one fresh, read-only subagent and explicitly assign it the `local-simplifier` skill. Require it to inspect the repository directly and return advisory candidates without editing.
3. Verify every candidate against the code and tests. If the subagent or skill is unavailable, disclose the fallback and apply the same simplification contract in the parent session.
4. Apply only verified, material improvements in the parent session. Do not change public behavior, broaden scope, or clean up unrelated pre-existing code.
5. Run the smallest relevant formatter, type checker, and tests. Inspect the final diff for accidental churn.

Summarize what was simplified, what verification ran, and any suggestion deliberately left unapplied because its tradeoff was not favorable. If no worthwhile simplification exists, leave the code unchanged and say so.
