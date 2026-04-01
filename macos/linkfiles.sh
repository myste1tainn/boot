#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "$0")" >/dev/null 2>&1; pwd -P)"

mkdir -p ~/.config/karabiner

find "$SCRIPT_DIR/karabiner" -mindepth 1 -type f | while IFS= read -r FILE; do
  DEST_NAME=$(basename "$FILE")
  ln -sf "$FILE" ~/.config/karabiner/"$DEST_NAME"
done
