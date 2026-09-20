# Dotfiles

`install.sh` links Vim, Neovim, durable Pi configuration, and portable agent
skills from this repository.

## New machine setup

Requires `git`, `make`, `patch`, and Node.js with npm. Pi is not installed by
this repository, so install the version the patches expect first:

```sh
npm install -g --ignore-scripts @earendil-works/pi-coding-agent@0.85.1
make install     # link configuration into $HOME
./pi/setup.sh    # install pinned Pi packages and apply compatibility patches
```

Then run `pi` and `/login`. Credentials, settings, sessions, and installed
packages stay machine-local.

## Managed paths

- `~/.vimrc`
- `~/.vim/`
- `~/.config/nvim/`
- `~/.pi/agent/AGENTS.md`
- `~/.pi/agent/extensions/`
- `~/.pi/agent/prompts/`
- `~/.pi/agent/skills/`
- `~/.agents/skills/`

## Commands

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
