#!/usr/bin/env bash
set -euo pipefail

REPO="https://github.com/myste1tainn/dotfiles-hammerspoon.git"
DEST="$HOME/.hammerspoon"

if [[ -d "$DEST/.git" ]]; then
  git -C "$DEST" pull --ff-only
else
  git clone "$REPO" "$DEST"
fi
