# Dotfiles

This repo uses GNU Stow as the symlink manager. Package folders stay
human-friendly, and `install.sh` maps each package to the right live target.

## Layout

- `vim/` links into `$HOME`, so it manages `~/.vimrc` and `~/.vim/`.
- `nvim/` links into `~/.config/nvim`, so the repo stays easy to edit as
  `nvim/init.lua`, `nvim/lua/...`, and `nvim/lazy-lock.json`.

## Commands

Install Stow first:

```sh
brew install stow
```

On Linux, use your package manager, for example `sudo apt install stow`.

Preview first-install backups and validate that Stow can plan the links:

```sh
make dry-run
```

Back up existing live Vim/Neovim config paths and link the repo:

```sh
make install
```

Re-link after package changes:

```sh
make restow
```

Remove Stow-managed symlinks:

```sh
make unstow
```

Backups made by `make install` are written under `~/.dotfiles-backup/`.
