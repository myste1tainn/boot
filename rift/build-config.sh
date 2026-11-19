#!/usr/bin/env bash
# Write ~/.config/rift/config.toml from the template in files/, with every
# "@EXTERNAL@" replaced by the names of the external monitors connected now.
# Rift only matches workspace_rules displays by exact name or UUID, so this
# lets workspaces 4-6 follow whatever monitor is plugged in.
#
# Usage: build-config.sh [MONITOR_NAME...]
#   With names (Hammerspoon passes them), use those; otherwise ask rift-cli.
#   Names starting with "Built-in" are always skipped.
# Rift hot-reloads the file; it is rewritten only when its content changes.
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "$0")" >/dev/null 2>&1; pwd -P)"
TEMPLATE="$SCRIPT_DIR/files/.config/rift/config.toml"
TARGET="$HOME/.config/rift/config.toml"
RIFT_CLI=/opt/homebrew/bin/rift-cli
JQ=/opt/homebrew/bin/jq

NAMES=()
if (($#)); then
  NAMES=("$@")
elif DISPLAYS="$("$RIFT_CLI" query displays 2>/dev/null)"; then
  while IFS= read -r NAME; do
    NAMES+=("$NAME")
  done < <("$JQ" -r '.[].name // empty' <<<"$DISPLAYS")
fi

# Quote each external name as a TOML string: "A", "B", (with trailing ", ").
LIST=""
for NAME in ${NAMES[@]+"${NAMES[@]}"}; do
  [[ -z "$NAME" || "$NAME" == Built-in* ]] && continue
  NAME="${NAME//\\/\\\\}"
  LIST+="\"${NAME//\"/\\\"}\", "
done

mkdir -p "$(dirname "$TARGET")"
# An older install symlinked the template here; replace it with a real file.
[[ -L "$TARGET" ]] && rm "$TARGET"

NEW="$(LIST="$LIST" awk '{ gsub(/"@EXTERNAL@", /, ENVIRON["LIST"]); print }' "$TEMPLATE")"
if [[ ! -f "$TARGET" ]] || [[ "$(cat "$TARGET")" != "$NEW" ]]; then
  printf '%s\n' "$NEW" >"$TARGET"
  echo "Rift config written with external monitors: ${LIST%, }"
fi
