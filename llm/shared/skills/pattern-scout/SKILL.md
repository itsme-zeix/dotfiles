---
name: pattern-scout
description: Finds cleaner patterns and precedents for a code or design question, without editing files.
disable-model-invocation: true
---

# Pattern scout

Research the code or design question given with the command. If none is given, use the one we're discussing. Don't edit files.

## Hand off

Launch one fresh, read-only subagent (not a fork of this conversation). Give it the question, the relevant files, and the Criteria section below. Ask it to return each candidate pattern with a file and line or a link, and whether it comes from this repo or from outside. If subagents aren't available, do the research yourself and say so.

## Criteria

- Check this repo's own conventions and helpers first. Look outside, including the web, when the repo has no good precedent.
- Suggest a pattern only if it makes this code simpler today. Skip indirection without a concrete benefit.
- If the current approach is already the clearest fit, say so. That's a valid result.

## Report

Check the scout's claims against the code and the cited sources. Lead with the recommended pattern and why it fits. Include file and line references, links for outside precedents, the tradeoffs, and a short sketch of how to apply it. Say which parts are repo convention and which are outside ideas.
