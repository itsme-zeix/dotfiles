# Dotfiles

GNU Stow is used only for Vim and Neovim right now.

Managed paths:

- `~/.vimrc`
- `~/.vim/`
- `~/.config/nvim/`

Install Stow:

```sh
brew install stow
```

On Linux, use your package manager, for example `sudo apt install stow`.

Preview what would happen:

```sh
make dry-run
```

Back up existing live Vim/Neovim paths and create the links:

```sh
make install
```

Remove Stow-managed links:

```sh
make unstow
```

Backups from `make install` go under `~/.dotfiles-backup/`.
