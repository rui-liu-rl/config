#!/bin/bash
# Set up a new Mac: Homebrew + packages, oh-my-zsh + plugins, Node, uv, and
# symlinks from $HOME into this repo. Safe to re-run.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

step() { printf '\n==> %s\n' "$*"; }

# ====== Homebrew ======
step "Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  if [ ! -x /opt/homebrew/bin/brew ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
# Login shells need brew on PATH too (the .zshrc fallback only covers interactive shells)
grep -qs 'brew shellenv' "$HOME/.zprofile" || echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
brew bundle --file="$DOTFILES_DIR/Brewfile" --no-upgrade

# ====== oh-my-zsh, powerlevel10k, plugins ======
step "oh-my-zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  # KEEP_ZSHRC: don't overwrite our .zshrc; RUNZSH: don't drop into a new shell
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
clone_if_missing() {
  [ -d "$2" ] || git clone --depth=1 "$1" "$2"
}
clone_if_missing https://github.com/romkatv/powerlevel10k "$ZSH_CUSTOM/themes/powerlevel10k"
clone_if_missing https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

# ====== Node (nvm) ======
step "Node"
export NVM_DIR="$HOME/.nvm"
mkdir -p "$NVM_DIR"
# nvm.sh isn't written for `set -u`
set +u
. "$(brew --prefix nvm)/nvm.sh"
nvm install 24
nvm alias default 24
set -u

# ====== uv ======
step "uv"
if [ ! -x "$HOME/.local/bin/uv" ]; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# ====== Symlinks ======
step "Symlinks"
link() {
  local src="$DOTFILES_DIR/$1"
  local dst="$HOME/$1"

  # Already pointing at the repo: nothing to do
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "ok        ~/$1"
    return
  fi

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$1")"
    mv "$dst" "$BACKUP_DIR/$1"
    echo "backed up ~/$1 -> $BACKUP_DIR/$1"
  fi

  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  echo "linked    ~/$1"
}

link .zshrc
link .p10k.zsh
link .gitconfig
link .wezterm.lua
link .config/ghostty
link .config/zellij
link .config/nvim
link .config/git

printf '\nDone. Open Ghostty to start.\n'
