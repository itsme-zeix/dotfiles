---
description: Research cleaner implementation patterns and relevant precedents
argument-hint: "[code, design question, or focus]"
---
Find better, cleaner implementation patterns for the supplied code or design question. Optional focus: $ARGUMENTS

This is read-only research. Do not edit files, apply fixes, commit, push, or post comments remotely.

## Scout independently

Launch exactly one fresh, read-only subagent and explicitly assign it both the `pattern-scout` and `ketch-research` skills. Require it to inspect the repository directly and return advisory recommendations without editing.

The parent must validate the scout's claims against the local code and cited sources. If the subagent or skills are unavailable, disclose the fallback and apply the same pattern-scout contract in the parent session. Recommendations are advisory, not authorization to edit.

## Output

Lead with the recommended pattern and why it fits. Include exact local references, links for external precedents, material tradeoffs, and a minimal implementation direction. Distinguish established repository convention from external inspiration. If the current approach is already the clearest fit, say so rather than inventing a refactor.
