---
name: review
description: Review a diff or working-tree changes for material bugs, regressions, and missing tests without editing files.
---

# Review

Review the target supplied with the invocation. If none is supplied, review staged, unstaged, and untracked working-tree changes. This is read-only: do not edit files, commit, push, or post comments remotely.

Read repository instructions and inspect the diff before surrounding code. Look for correctness failures, regressions, security boundary violations, misleading or missing tests, and concrete maintenance risks introduced by the change. Reject speculative, stylistic, and pre-existing complaints.

Launch two fresh, read-only subagents to review the same target independently. Give each the review criteria above and require findings with exact file and line references. Do not share either pass's conclusions with the other. If subagents are unavailable, review directly and disclose the fallback.

Validate every candidate against the diff, relevant code, and tests. Deduplicate overlapping findings; agreement is not a substitute for validation.

Report findings first, ordered by severity. For each, include an exact file and line, concrete impact, the changed behavior causing it, and a minimal remediation direction. Then list assumptions and verification gaps. If there are no material findings, say so explicitly.
