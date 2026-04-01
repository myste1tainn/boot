#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "$0")" >/dev/null 2>&1; pwd -P)"

bash "$SCRIPT_DIR/linkfiles.sh"

# Install WezTerm terminfo so TERM=wezterm works in remote sessions
if ! infocmp wezterm &>/dev/null; then
  tmpfile=$(mktemp)
  curl -fsSL https://raw.githubusercontent.com/wezterm/wezterm/main/termwiz/data/wezterm.terminfo \
    -o "$tmpfile"
  tic -x -o ~/.terminfo "$tmpfile"
  rm "$tmpfile"
fi
