# Dotfiles

Configuration for Vim, Neovim, Pi, Claude, Codex, Kitty, Ghostty, and VS Code.

- `vim/`, `nvim/`, `cli/`, `vscode/`: editor and terminal settings.
- `llm/pi/`: Pi configuration and installer.
- `llm/claude/`, `llm/codex/`: settings to apply manually, and scripts that link the shared instructions and skills.
- `llm/shared/`: shared agent instructions and skills.

To set up Pi (requires Node.js, npm, and `patch`):

```sh
./llm/pi/install.sh
```

To link the shared instructions and skills into Claude Code and Codex:

```sh
./llm/claude/update-symlinks.sh
./llm/codex/update-symlinks.sh
```

Both scripts read `SHARED_DIR` (default `llm/shared`) to find `AGENTS.md` and the skills. The Claude script reads `CLAUDE_CONFIG_DIR` (default `~/.claude`), and the Codex script reads `CODEX_HOME` (default `~/.codex`).

See `llm/pi/README.md` for Pi details. Other settings are applied manually.
