#!/usr/bin/env bash
# Clone the private Alfred sync repo and point Alfred's "Sync" preference at it.
# Needs GitHub access (gh auth login) because the repo is private; skips cleanly without it.
set -euo pipefail

REPO="myste1tainn/alfred"
DEST="$HOME/.alfred"
DOMAIN="com.runningwithcrayons.Alfred-Preferences"

if [[ -d "$DEST/.git" ]]; then
  git -C "$DEST" pull --ff-only
elif gh auth status >/dev/null 2>&1; then
  gh repo clone "$REPO" "$DEST"
else
  echo "  ! Alfred prefs skipped: run 'gh auth login', then 'bash $0'" >&2
  exit 0
fi

# Alfred rewrites its prefs on quit, so set the key while it is not running.
was_running=0
if pgrep -x Alfred >/dev/null; then was_running=1; osascript -e 'quit app "Alfred 6"' || true; sleep 2; fi
defaults write "$DOMAIN" syncfolder -string "$DEST"
[[ $was_running -eq 1 ]] && open -a "Alfred 6"
echo "  ✓ Alfred sync folder -> $DEST"
