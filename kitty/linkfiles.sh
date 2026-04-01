#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "$0")" >/dev/null 2>&1; pwd -P)"

mkdir -p ~/.config/kitty

for FILE in kitty.conf current-theme.conf; do
  ln -sf "$SCRIPT_DIR/$FILE" ~/.config/kitty/$FILE
done
