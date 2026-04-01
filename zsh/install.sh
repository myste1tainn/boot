#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "$0")" >/dev/null 2>&1; pwd -P)"

# Install oh-my-zsh if not present (non-interactive, does not change default shell)
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  RUNZSH=no CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# zsh-autosuggestions — referenced in plugins=() in .zshrc
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# materialshell theme — ZSH_THEME="materialshell" in .zshrc (not built-in)
if [[ ! -d "$ZSH_CUSTOM/themes/materialshell" ]]; then
  git clone --depth=1 https://github.com/carloscuesta/materialshell \
    "$ZSH_CUSTOM/themes/materialshell"
  ln -sf "$ZSH_CUSTOM/themes/materialshell/materialshell.zsh-theme" \
    "$ZSH_CUSTOM/themes/materialshell.zsh-theme"
fi

# Link .zshrc (overwrites the one omz just created)
ln -sf "$SCRIPT_DIR/zshrc" ~/.zshrc
