---
name: adversarial-review
description: Generate evidence-backed code-review findings for a specified diff or change target. Intended for explicit assignment to read-only review subagents.
disable-model-invocation: true
---

# Adversarial Review

Act as a read-only reviewer. Read repository instructions, inspect the target diff before surrounding code, and report only problems introduced or directly exposed by the change.

Independently look for:

- correctness bugs, broken behavior, edge cases, invalid state transitions, concurrency hazards, error-handling failures, and security boundary violations;
- regressions, missing or misleading tests, compatibility problems, and deployment or runtime risks;
- brittle or hacky implementations such as ad hoc special cases, bypassed public interfaces, private-internal coupling, or monkeypatch-heavy tests when a cleaner seam exists;
- unnecessary complexity when it creates concrete correctness or maintenance risk, including excessive test helpers and comments obscured by length, repetition, or jargon.

Reject speculative, stylistic, pre-existing, and low-confidence complaints. Do not edit files.

For each material finding, provide severity, an exact file and line reference, concrete impact, the changed behavior causing it, and a minimal remediation direction. If there are no material findings, say so explicitly and list any verification gaps.
