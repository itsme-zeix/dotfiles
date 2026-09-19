# Dotfiles

`install.sh` links Vim, Neovim, durable Pi configuration, and portable agent
skills from this repository.

Managed paths:

- `~/.vimrc`
- `~/.vim/`
- `~/.config/nvim/`
- `~/.pi/agent/AGENTS.md`
- `~/.pi/agent/extensions/`
- `~/.pi/agent/prompts/`
- `~/.pi/agent/skills/`
- `~/.agents/skills/`

Preview the links and any required backups:

```sh
make dry-run
```

Back up conflicting targets and create the links:

```sh
make install
```

Create links only when no target conflicts:

```sh
make link
```

Remove only links that point into this repository:

```sh
make unlink
```

Backups from `make install` go under `~/.dotfiles-backup/`. Pi authentication, sessions, settings, caches, and installed packages remain unmanaged.
