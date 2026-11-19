#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "$0")" >/dev/null 2>&1; pwd -P)"

# ~/.config/rift/config.toml is generated from files/.config/rift/config.toml
# (it fills in the connected external monitors), so it is built, not linked.
# Hammerspoon rebuilds it on monitor changes; see hammperspoon/files/init.lua.
bash "$SCRIPT_DIR/build-config.sh"
