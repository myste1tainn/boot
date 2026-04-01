#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "$0")" >/dev/null 2>&1; pwd -P)"

mkdir -p ~/.hammerspoon

ln -sf "$SCRIPT_DIR/files/init.lua" ~/.hammerspoon/init.lua
