---
name: pattern-scout
description: Research cleaner implementation patterns and relevant precedents for a code or design question without editing files.
---

# Pattern Scout

Research the code or design question supplied with the invocation. This is read-only: do not edit files, commit, push, or post comments remotely.

Launch one fresh, read-only subagent to inspect repository conventions and reusable utilities first, then relevant language or framework guidance and comparable implementations where they materially help. Give it the question and any focus supplied with the invocation. It may use `ketch-research` when current external evidence is needed. Require advisory recommendations without edits. If subagents are unavailable, do the research yourself and disclose the fallback.

Validate the scout's claims against local code and cited sources. Compare each candidate with this repository's constraints and reject indirection without a concrete benefit. Lead with the recommended pattern and why it fits. Include exact local references, links for external precedents, material tradeoffs, and a minimal implementation direction. Distinguish repository convention from external inspiration. If the current approach is already the clearest fit, say so.
