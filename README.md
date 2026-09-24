# Dotfiles

Configuration for Vim, Neovim, Pi, Claude, Codex, Kitty, Ghostty, and VS Code.

- `vim/`, `nvim/`, `cli/`, `vscode/`: editor and terminal settings.
- `llm/pi/`: Pi configuration and installer.
- `llm/claude/`, `llm/codex/`: settings to apply manually.
- `llm/shared/`: shared agent instructions and skills.

To set up Pi (requires Node.js, npm, and `patch`):

```sh
./llm/pi/install.sh
```

See `llm/pi/README.md` for Pi details. Other settings are applied manually.
