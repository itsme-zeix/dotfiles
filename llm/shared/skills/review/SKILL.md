---
name: review
description: Reviews a diff, commit, branch, PR, or working-tree changes for real bugs, regressions, and missing tests, without editing files.
disable-model-invocation: true
---

# Review

Review the target given with the command: a diff, commit, branch, or PR. If none is given, review the working-tree changes: `git diff HEAD` plus the untracked files `git status` lists. Don't edit files, commit, push, or post comments.

## Hand off

Launch two fresh, read-only subagents (not forks of this conversation) to review the same target independently. Give each the exact target, the goal of the change if you know it but not your reasoning about the code, and the Criteria section below. Ask each to return findings with file and line, what goes wrong, and the change that causes it. Don't share one pass's findings with the other. If subagents aren't available, review it yourself and say so.

## Criteria

Read the repository instructions, then the diff, then the surrounding code and tests you need. Report only:

- Bugs and regressions the change introduces.
- Security holes the change opens.
- Tests that are wrong or misleading, and missing tests only where a realistic bug in the change would go uncaught.

Skip style, speculation, and problems that existed before the change. Finding nothing is a valid result.

## Report

Check every finding against the diff, code, and tests yourself, and merge duplicates. Two passes agreeing doesn't make a finding true.

List findings first, most severe first. For each, give the file and line, what goes wrong, the change that causes it, and the smallest fix. Then list assumptions and anything you couldn't check. If there are no findings, say so.
