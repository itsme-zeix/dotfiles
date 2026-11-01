---
name: devils-advocate
description: Steelmans a proposal, decision, or plan, stress-tests it from a fresh perspective, then gives a verdict. Read-only.
disable-model-invocation: true
---

# Devil's advocate

Find the strongest reasons not to go ahead with the proposal given with the command. If none is given, use the one we're discussing. If the proposal or its goal is unclear, ask one question first. Don't edit files or start building anything.

## Get an outside view

You probably helped shape this proposal, so its flaws are hard for you to see. Hand the critique to one fresh, read-only subagent (not a fork of this conversation). Give it the proposal, its goal, the known constraints, the relevant files, and the Critique section below, but not the arguments for it. Ask it to return its steelman and, for each objection, the scenario, how likely it is, and the evidence. If subagents aren't available, do the critique yourself and say so.

## Critique

Steelman the proposal first: build its strongest version and the best case for it. Then attack that version, not a weaker one:

- Imagine it's six months later and this went badly. Say what most likely went wrong.
- Compare it with the strongest alternative, including doing nothing. A flaw only matters if the alternative avoids it.
- Find the assumptions it depends on and check them against the code, docs, or other sources. Say which ones you couldn't check.
- Say how hard it would be to undo. The easier it is to reverse, the less certainty it needs.
- Tie each objection to a concrete scenario in this proposal, not a generic concern like "consider scalability".

Raise only objections that would change the decision. Finding none is a valid result.

## Report

Drop an objection only if the evidence contradicts it. If you just disagree, keep it and add your rebuttal. If the subagent's steelman missed part of the real case, add it and say whether the objections still hold.

- **Proposal:** one or two sentences, including its goal.
- **Steelman:** the best case for it, in a few sentences.
- **Objections:** strongest first. For each, say what goes wrong, how likely it is, and the smallest change that would prevent it.
- **Unchecked assumptions:** the ones nobody could verify.
- **Verdict:** go ahead, go ahead with changes, or rethink it, weighing how hard it is to undo. Say what evidence would change the verdict.

If the proposal holds up, say so plainly.
