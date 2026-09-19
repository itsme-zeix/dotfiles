# Pi configuration

The repository linker installs durable Pi configuration into `~/.pi/agent`:

- `AGENTS.md`
- `extensions/btw-autocomplete.ts`
- `extensions/project-status.ts`
- `extensions/mutation-stats.ts`
- `extensions/turn-timer.ts`
- `extensions/workflow.ts`
- `skills/adversarial-review/SKILL.md`
- `skills/ketch-research/SKILL.md`
- `skills/local-simplifier/SKILL.md`
- `skills/pattern-scout/SKILL.md`
- `prompts/devils-advocate.md`
- `prompts/pattern-scout.md`
- `prompts/review.md`
- `prompts/review-and-simplify.md`
- `prompts/simplify.md`

Runtime state remains local and untracked, including authentication, sessions, settings, caches, and installed packages.

Install the links from the dotfiles repository root:

```sh
./install.sh install pi
```

Install the runtime packages with pinned versions and apply the tracked
static subagent step indicators and Pi compatibility patches:

```sh
./pi/setup.sh
```

`setup.sh` and `patches/` stay in the repository. The explicit link installer
does not place them under `~/.pi/agent`.

The setup script also installs Ketch through Homebrew when missing. On a new
Ketch installation it selects the zero-key DuckDuckGo backend; existing Ketch
configuration is left unchanged. `/skill:ketch-research` loads the tracked,
CLI-only research workflow. Ketch configuration, credentials, and cache remain
machine-local.

The `adversarial-review`, `local-simplifier`, and `pattern-scout` skills are
hidden from normal model invocation and assigned explicitly to fresh subagents
by `/review`, `/simplify`, `/pattern-scout`, and `/review-and-simplify`. The
commands own orchestration and edit policy; the skills own reusable leaf-agent
behavior.

`/btw` is the Claude-style one-shot side question from `pi-mono-btw`. It
intercepts input directly rather than registering a command, which is what keeps
it usable while the main agent is still running. The tracked `btw-autocomplete`
extension adds the entry to the slash-command menu without registering a
command, since a registered `/btw` would take precedence over input expansion and
shadow the real handler. `Ctrl+Shift+B` asks the current editor text as a side
question.

The tracked `project-status` extension renders a compact one-line footer with
the current directory, Git branch and change count, GitHub PR, extension
statuses, cost, context usage, response speed, model, and effort. Run
`/status-refresh` to refresh Git and PR state manually.

The tracked `workflow` extension adds a transcript-native `/diff` viewer and a
persistent `/goal` command with `edit`, `pause`, `resume`, and `clear` actions.
Pi already provides `/copy` for copying the last assistant response.

The tracked `mutation-stats` extension preserves Pi's built-in edit and write
renderers while adding Codex-style `(+N -M)` line counts to completed mutation
headers.

The tracked `turn-timer` extension adds elapsed time to Pi's working indicator,
shows `pi (.../parent/project)` plus an optional session name in the terminal
tab, animates the tab while Pi is active, and writes a Codex-style
`Worked for ...` divider when each agent run settles. Cancellations longer than
one minute instead render as `Operation aborted (worked for ...)` on one line.
