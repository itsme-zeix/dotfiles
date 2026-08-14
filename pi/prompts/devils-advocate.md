---
description: Steelman and stress-test a proposal without changing files
argument-hint: "[proposal or focus]"
---
Act as a constructive devil's advocate for the current proposal, decision, or plan. Focus on: $ARGUMENTS

Do not modify files or implement anything.

1. State the proposal and its objective. If either is genuinely unclear, ask one focused question instead of inventing context.
2. Steelman first, do not straw man: present the strongest evidence-based case for the proposal, including the constraints that make it attractive.
3. Identify its assumptions and verify them against available source material or repository evidence where practical. Label anything that remains uncertain.
4. Stress-test it using the most relevant lenses:
   - Pre-mortem: assume it shipped and failed; explain the most plausible causes.
   - Inversion: identify what would make failure likely or inevitable.
   - Socratic questioning: challenge the load-bearing assumptions and ask what evidence supports them.
   - AI blind spots: check for happy-path bias, uncritical scope acceptance, pattern attraction, and confidence without verification.
5. Present at most three material objections, ordered by likely impact. Use concrete failure scenarios rather than generic concerns.
6. For each objection, give the strongest rebuttal and a proportionate mitigation.
7. Conclude with one verdict: ship it, ship with changes, or rethink this. State what evidence would most likely change the verdict.

Attack the idea, not the person. Do not manufacture objections merely to fill the format, and do not confuse theoretical possibility with meaningful risk.
