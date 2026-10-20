# Config

Dotfiles. On a new Mac:

```sh
git clone https://github.com/rui-liu-rl/config.git ~/codes/rui/config
~/codes/rui/config/install.sh
```

The script installs Homebrew and everything in `Brewfile`, oh-my-zsh + powerlevel10k + zsh-autosuggestions,
Node 24 (nvm) and uv, then symlinks these into `$HOME`: `.zshrc`, `.p10k.zsh`, `.gitconfig`, `.wezterm.lua`,
`.config/{ghostty,zellij,nvim,git}`. Anything it replaces is moved to `~/dotfiles_backup_<timestamp>/`.
It's safe to re-run.

Git identity isn't tracked — `.gitconfig` includes `~/.gitconfig.local`, so create it on a new machine:

```sh
git config --file ~/.gitconfig.local user.name "Your Name"
git config --file ~/.gitconfig.local user.email "you@example.com"
```

Since the files are symlinked, editing `~/.config/...` edits this repo — commit the changes here.

## Terminal

Ghostty opens straight into Zellij (bottom tab bar, `Ctrl+A` leader, tmux-style keys — see `.config/zellij/config.kdl`).

## Notable shortcuts

* Single tab will invoke the regular auto completion
* Double tab will take the completion suggested by zsh-autosuggestions plugin
