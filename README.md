# Dotfiles

GNU Stow manages Vim, Neovim, and durable Pi agent configuration.

Managed paths:

- `~/.vimrc`
- `~/.vim/`
- `~/.config/nvim/`
- `~/.pi/agent/AGENTS.md`
- `~/.pi/agent/extensions/`
- `~/.pi/agent/prompts/`
- `~/.pi/agent/skills/`

Install Stow:

```sh
brew install stow
```

On Linux, use your package manager, for example `sudo apt install stow`.

Preview what would happen:

```sh
make dry-run
```

Back up existing live Vim, Neovim, and Pi paths and create the links:

```sh
make install
```

Remove Stow-managed links:

```sh
make unstow
```

Backups from `make install` go under `~/.dotfiles-backup/`. Pi authentication, sessions, settings, caches, and installed packages remain unmanaged.
