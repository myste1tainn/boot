#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "$0")" >/dev/null 2>&1; pwd -P)"

ln -sf "$SCRIPT_DIR/home/dotfiles/tmux.conf" ~/.tmux.conf

mkdir -p ~/.config/tmuxinator
ln -sf "$SCRIPT_DIR/tmuxinator" ~/.config/tmuxinator
