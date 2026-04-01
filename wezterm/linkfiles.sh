#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "$0")" >/dev/null 2>&1; pwd -P)"

mkdir -p ~/.config/wezterm
ln -sf "$SCRIPT_DIR/wezterm.lua" ~/.config/wezterm/wezterm.lua
