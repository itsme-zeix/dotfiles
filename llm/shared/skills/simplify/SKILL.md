---
name: simplify
description: Simplify current code changes while preserving intended behavior and staying within the changed scope.
---

# Simplify

Inspect the current diff, relevant code, dependencies, and repository instructions. Use any focus supplied with the invocation. Restrict edits to changed files unless a directly required adjustment cannot be made otherwise.

Look for material simplifications: existing utilities that remove duplication, clearer control flow, avoidable abstraction, and brittle special cases. Consider comments or test helpers only when their complexity obscures the changed behavior. Reject cosmetic churn and speculative generalization.

Launch one fresh, read-only subagent to find simplification candidates using those criteria. Require it to inspect the changes directly and return recommendations without editing. If subagents are unavailable, do the analysis yourself and disclose the fallback.

Verify each candidate against the code and relevant tests. Apply only improvements that preserve intended behavior in the parent session. Run the smallest useful validation and inspect the final diff for accidental changes.

Summarize what changed, what verification ran, and any suggestion left unapplied because its tradeoff was unfavorable. If no worthwhile simplification exists, leave the code unchanged and say so.
