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

# Alfred 5/6 ignore the old "syncfolder" default. They read the location from
# prefs.json and only accept it reliably when the default
# "Alfred.alfredpreferences" path is itself a symlink to the clone, so do both.
# Alfred rewrites its files on exit, so it must be fully stopped first.
SUPPORT="$HOME/Library/Application Support/Alfred"
LINK="$SUPPORT/Alfred.alfredpreferences"
pkill -x Alfred || true
for _ in 1 2 3 4 5 6; do pgrep -x Alfred >/dev/null || break; sleep 1; done
mkdir -p "$SUPPORT"
if [[ -e "$LINK" && ! -L "$LINK" ]]; then mv "$LINK" "$LINK.local-backup-$(date +%s)"; fi
ln -sfn "$DEST/Alfred.alfredpreferences" "$LINK"
if [[ -f "$SUPPORT/prefs.json" ]]; then
  python3 - "$SUPPORT/prefs.json" "$DEST/Alfred.alfredpreferences" <<'PY'
import json, sys
p, cur = sys.argv[1:3]
d = json.load(open(p)); d["current"] = cur
json.dump(d, open(p, "w"), indent=2)
PY
fi
defaults delete com.runningwithcrayons.Alfred-Preferences syncfolder 2>/dev/null || true
open -a "Alfred 6" 2>/dev/null || true
echo "  ✓ Alfred preferences -> $DEST/Alfred.alfredpreferences"
