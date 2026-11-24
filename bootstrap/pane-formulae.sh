#!/usr/bin/env bash
# Left panes 1 and 2: each installs one half of the Brewfile.
# Usage: pane-formulae.sh <lock-name> <half-brewfile>
set -uo pipefail
source "$(dirname "$0")/lib.sh"

NAME="$1"
FILE="$2"
export HOMEBREW_NO_AUTO_UPDATE=1 # bootstrap.sh already ran `brew update`

log "[$NAME] $(grep -cE '^(brew|cask) ' "$FILE") packages from $FILE"
brew bundle --file="$FILE" 2>&1 | tee "/tmp/brew-$NAME.log"
rc=${PIPESTATUS[0]}

if [[ $rc -eq 0 ]]; then ok "[$NAME] done"; else fail "[$NAME] brew bundle exited $rc — see /tmp/brew-$NAME.log"; fi
mark_done "$NAME" "$rc"
