# Pi setup

Run `./llm/pi/install.sh` from the repository root. It installs the pinned Pi
version if absent and refuses to patch a different version. It also installs
pinned Pi packages, applies the tracked patches, and links these files into
`~/.pi/agent`:

- `AGENTS.md` (from `llm/shared/AGENTS.md`)
- `extensions/btw-autocomplete.ts`
- `extensions/escape-send-queued.ts`
- `extensions/project-status.ts`
- `extensions/mutation-stats.ts`
- `extensions/subagent-cost.ts`
- `extensions/turn-timer.ts`
- `extensions/workflow.ts`
- `skills/<name>/` (from `llm/shared/skills/`)

The installer checks all link targets before changing them, replaces only links
from the previous Pi layout, and stops on unrelated files. It does not manage
Claude, Codex, or other dotfiles. The former prompt commands are now available
as `/skill:review`,
`/skill:review-and-simplify`, `/skill:simplify`, `/skill:pattern-scout`, and
`/skill:devils-advocate`.

Runtime state remains local and untracked, including authentication, sessions,
settings, caches, and installed packages. `install.sh` and `patches/` stay in
the repository rather than being linked into `~/.pi/agent`.

The setup script also installs Ketch through Homebrew when missing. On a new
Ketch installation it selects the zero-key DuckDuckGo backend; existing Ketch
configuration is left unchanged. `/skill:ketch-research` loads the tracked,
CLI-only research workflow. Ketch configuration, credentials, and cache remain
machine-local.

The five review and research workflows are self-contained skills. Review,
simplification, and pattern scouting delegate read-only analysis to subagents;
the parent validates their recommendations and makes any authorized edits.

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

The tracked `subagent-cost` extension reports delegated subagent spend back to
Pi. `pi-subagents` records child token and cost totals under the tool result's
`details`, which Pi's session totals ignore, so delegated work was missing from
the footer, `/session`, and RPC cost totals. The extension re-reports the
combined child usage as tool result `usage`, which restores it to every total Pi
derives from the session.

Runs that finish inside their `subagent` call are counted from the totals on that
result. Async runs have no cost at launch, so they are counted when
`subagent_wait` delivers the completion, by reading each child's session file.
Reported totals are tracked per child session, so a resumed run contributes only
its new spend. The remaining gap is an async run whose completion arrives solely
as a custom message wake: custom messages cannot carry usage, and Pi counts child
sessions only once their cost reaches the parent session.

The tracked `turn-timer` extension adds elapsed time to Pi's working indicator,
shows `pi (.../parent/project)` plus an optional session name in the terminal
tab, animates the tab while Pi is active, and writes a Codex-style
`Worked for ...` divider when each agent run settles. Cancellations longer than
one minute get an `Aborted after ...` divider instead.

The tracked `escape-send-queued` extension makes Escape during a run with
queued messages abort the turn and send the queue immediately, as Claude Code
does. Without a queue, Escape interrupts as usual. Pi reserves Escape for its
own interrupt, so the extension intercepts raw terminal input and recovers the
queued text from the editor, where Pi's abort restores it. Only text survives:
extension-queued images and custom messages are dropped, as with stock Escape.
