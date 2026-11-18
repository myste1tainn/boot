#!/usr/bin/env bash
# Toggle the focused Rift workspace between tiles ("traditional") and every
# window full-size in a stack, like AeroSpace's tiles <-> accordion layouts.
# Bound in config.toml; Rift runs it from launchd, so use absolute paths.
set -euo pipefail

RIFT_CLI=/opt/homebrew/bin/rift-cli
JQ=/opt/homebrew/bin/jq

MODE="$("$RIFT_CLI" query workspaces | "$JQ" -r 'first(.[] | select(.is_focused)) | .layout_mode')"

if [[ "$MODE" == "stack" ]]; then
  "$RIFT_CLI" execute workspace set-layout traditional
else
  "$RIFT_CLI" execute workspace set-layout stack
fi
