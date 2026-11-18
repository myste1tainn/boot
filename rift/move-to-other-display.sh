#!/usr/bin/env bash
# Move the focused window to the next display, wrapping around: with two
# displays that is always "the other one", whichever side macOS put it on.
# Like AeroSpace's 'move-node-to-monitor next --wrap-around'.
# Bound in config.toml; Rift runs it from launchd, so use absolute paths.
set -euo pipefail

RIFT_CLI=/opt/homebrew/bin/rift-cli
JQ=/opt/homebrew/bin/jq

# The focused window's display is the one holding its centre; Rift's own
# "active" display follows the mouse, which may be elsewhere.
WIN="$("$RIFT_CLI" query windows | "$JQ" -c 'first(.[] | select(.is_focused)) | .frame')"
[[ -n "$WIN" && "$WIN" != null ]] || exit 0

NEXT="$("$RIFT_CLI" query displays | "$JQ" -r --argjson w "$WIN" '
  ($w.origin.x + $w.size.width / 2) as $cx
  | ($w.origin.y + $w.size.height / 2) as $cy
  | length as $n
  | (to_entries
     | map(select(.value.frame as $f
         | $cx >= $f.origin.x and $cx < $f.origin.x + $f.size.width
           and $cy >= $f.origin.y and $cy < $f.origin.y + $f.size.height))
     | first | .key // 0) as $i
  | if $n < 2 then empty else .[($i + 1) % $n].uuid end')"

if [[ -n "$NEXT" ]]; then "$RIFT_CLI" execute display move-window --uuid "$NEXT"; fi
