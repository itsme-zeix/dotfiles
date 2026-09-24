# Dotfiles

This repository keeps Vim, Neovim, Pi, Claude, Codex, terminal, and VS Code
configuration together. Only Pi has an installer; the other configurations are
applied manually to suit each machine.

## New machine setup

Pi setup requires Node.js with npm and `patch`. Run its installer from the
repository root:

```sh
./llm/pi/install.sh
```

It installs the pinned Pi version if absent, installs the pinned Pi packages,
applies compatibility patches, and links Pi instructions, extensions, and shared
skills. It stops rather than replacing an existing different Pi version or an
unrelated Pi file. Then run `pi` and `/login`. See `llm/pi/README.md` for details.

## Configuration

- `vim/` and `nvim/` hold editor configuration.
- `llm/pi/` holds Pi extensions, patches, and its installer.
- `llm/claude/settings.json` and `llm/codex/config.toml` are reference settings;
  merge the preferences you want into each machine's live configuration rather
  than replacing app-managed settings wholesale.
- `llm/shared/AGENTS.md` is the common working agreement. The Pi installer links
  it to `~/.pi/agent/AGENTS.md`; Claude and Codex can use the same source for
  their global instruction files.
- `cli/kitty.conf`, `cli/ghostty.conf`, and `vscode/settings.json` are for manual
  use. The VS Code settings pass Ctrl+C, Ctrl+V, Ctrl+F, and Ctrl+B to its
  integrated terminal.

`llm/shared/skills/` is the source for all three agents. Pi loads these skills
from `~/.pi/agent/skills/` and invokes them as `/skill:name`. Link the skill
folders manually for Codex (`~/.agents/skills/`) and Claude
(`~/.claude/skills/`) on machines where you use them. Codex invokes `$name`,
and Claude invokes `/name`. The former Pi prompt workflows are now skills, so
`/review` becomes `/skill:review` in Pi.
