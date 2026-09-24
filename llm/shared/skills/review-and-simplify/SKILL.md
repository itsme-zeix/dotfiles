---
name: review-and-simplify
description: Review current changes and recommend behavior-preserving simplifications and cleaner patterns without editing files.
---

# Review and Simplify

Review the current working-tree changes, using any focus supplied with the invocation. This is read-only: do not edit files, commit, push, or post comments remotely.

Read repository instructions, inspect staged, unstaged, and untracked changes, and then read the surrounding code and tests needed to understand them. Keep recommendations within the changed scope.

Launch four fresh, read-only subagent passes: two independent correctness reviews of the same target, one search for behavior-preserving simplifications, and one search for cleaner patterns. Give each the target and relevant criteria, and require direct inspection of the repository without edits. The pattern scout may use `ketch-research` when external evidence would change a recommendation. Run passes in waves if the host limits concurrency. Do not share conclusions between passes before they finish. If subagents are unavailable, perform the passes yourself and disclose the fallback.

Validate every candidate against the diff, code, and tests. Separate correctness findings from behavior-preserving simplification and pattern recommendations, and identify dependencies between them. Do not implement recommendations.

Report correctness findings first by severity with exact file and line references, impact, cause, and minimal remediation direction. Then report worthwhile simplifications and patterns with benefits and tradeoffs. Explain any material suggestion you rejected or could not verify. If there are no material findings or recommendations, say so.
