---
name: show-me-your-work
description: Keeps a reviewable decision log for long or unattended runs, with one TSV row per decision (what, why, evidence, result). Use for multi-phase runs or work someone reviews after stepping away.
disable-model-invocation: true
---

# Show me your work

Keep one decision log for the run, so someone who stepped away can check what you did and why.

## The format

A TSV file with one row per decision. Cells stay on one line. Evidence is a pointer, not prose. Columns:

- **ts.** ISO 8601 timestamp.
- **phase.** The phase or workstream.
- **decision.** What was chosen or done, in one line.
- **why.** The reason in plain words.
- **evidence.** A pointer that proves it: commit SHA, PR number, `file:line`, or an artifact, trace, or screenshot path.
- **result.** The outcome, such as `tests green`, `reverted`, `pixel-diff 0`, `INCONCLUSIVE`, or `open`.

Write rows the way you'd tell a teammate what you did:

```
ts	phase	decision	why	evidence	result
2026-05-24T09:02:00Z	frame	counted the work first, about 100 components and roughly 75 hours	wanted to know the size before starting a long run	commit 3a9f1c2	found 5 things to sort out before starting
2026-05-24T09:40:00Z	harness	took screenshots of the old version before changing anything	so we can compare old against new and catch any visual change	scripts/snapshot.sh, baseline/	saved 120 reference screenshots
2026-05-24T12:30:00Z	widget	threw out a helper's work because its screenshots were blank	checked the real files instead of trusting its summary	worktree reset	reverted, tightened the instructions for next time
```

## Logging a row

Run `scripts/log.sh <logfile> <phase> <decision> <why> <evidence> <result>` from this skill's folder. It adds the timestamp, writes the header on first use, keeps cells on one line, and stops cells from being read as spreadsheet formulas.

Log decision points and checkpoints, not every action: a fork you chose, a finished unit with its check result, a pivot or revert and what triggered it, a blocker. For loops, log one row per iteration.

## Where it lives

Keep the log at `decisions.tsv` in the work directory, or `.audit/<task-slug>.tsv` when several efforts run at once, and leave it out of git. Commit it only when a reviewer needs the trail to trust the result.

The log is append-only. Fix a wrong call with a new row that replaces it. Never edit or delete rows.

## Check the log before handing back

Work out where this harness stores the current session's transcript. If you find it, check this run's rows against it:

- Every row matches a real decision or action.
- Each row's evidence exists and shows what the row claims.
- Any fork, pivot, or abandoned approach that shaped the work has a row. Add the missing ones.

Fix problems with new rows, never by editing old ones. If you can't find the transcript, skip this check and say so.

## Get the trail reviewed

Have a fresh subagent (not a fork of this conversation) read the log and the transcript, and flag what the user should look at: decisions with weak evidence, checks claimed without proof, risky choices, and gaps a quick skim would miss. Use a model from a different provider if the harness offers one. Otherwise, say the reviewer is from the same model family.

End your reply with an "Attention" section. Start it with `reviewed by <model>`, then list each flag with the rows or moments it points to. "No flags" is a valid result.
