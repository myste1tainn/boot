#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname "$0")" >/dev/null 2>&1; pwd -P)"
mkdir -p "$HOME/.config/neovide"
ln -sf "$SCRIPT_DIR/config.toml" "$HOME/.config/neovide/config.toml"
