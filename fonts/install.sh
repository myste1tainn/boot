#!/usr/bin/env bash
# Install every Nerd Font cask Homebrew knows about.
#
# The list is discovered at run time rather than pinned, so new Nerd Fonts are
# picked up automatically and renamed/removed ones never break the bootstrap.
#
# Note: homebrew/cask-fonts is NOT tapped — it was deprecated and emptied in
# 2024 and all font casks were migrated into homebrew/cask. Tapping it now
# fails with "this tap is now empty".
set -uo pipefail

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok() { printf '\033[1;32m  ✓\033[0m %s\n' "$*"; }

log "Discovering Nerd Font casks..."
# brew search columnises on a tty and lists one per line when piped; tr covers
# both. The grep keeps only real cask names (drops "==> Casks" style headers).
fonts=$(brew search '/font-.*-nerd-font/' 2>/dev/null \
  | tr -s '[:space:]' '\n' \
  | grep -E '^font-[^[:space:]]*nerd-font' \
  | sort -u)

if [[ -z "$fonts" ]]; then
  printf '\033[1;33m  !\033[0m No Nerd Font casks found — skipping\n'
  exit 0
fi

log "Installing $(printf '%s\n' "$fonts" | wc -l | tr -d ' ') Nerd Fonts..."
# Already-installed casks exit non-zero; keep going regardless.
printf '%s\n' "$fonts" | xargs -I{} brew install --cask {} || true
ok "Nerd Fonts installed"
