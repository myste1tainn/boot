#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "$0")" >/dev/null 2>&1; pwd -P)"

ln -sf "$SCRIPT_DIR/home/dotfiles/tmux.conf" ~/.tmux.conf

# Link individual session files; symlinking the directory itself into an
# already-existing ~/.config/tmuxinator would create a nested symlink.
mkdir -p ~/.config/tmuxinator
find "$SCRIPT_DIR/tmuxinator" -maxdepth 1 -name "*.yml" | while IFS= read -r FILE; do
  ln -sf "$FILE" ~/.config/tmuxinator/"$(basename "$FILE")"
done
