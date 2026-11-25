#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "$0")" >/dev/null 2>&1; pwd -P)"

bash "$SCRIPT_DIR/linkfiles.sh"


# Hide Karabiner profile switches (Hammerspoon flips "selected" on the live, symlinked
# karabiner.json) from git. Filter config is local to .git/config, so set it on every clone.
git -C "$SCRIPT_DIR/.." config filter.karabiner-profile.clean 'python3 macos/karabiner/normalize-profile.py'
git -C "$SCRIPT_DIR/.." config filter.karabiner-profile.required false
