#!/usr/bin/env bash
# Switch the active tiling window manager between Rift and AeroSpace.
# Two tiling WMs fight over the same windows, so only one may run at a time.
#   bash rift/switch.sh rift       # stop AeroSpace, start Rift
#   bash rift/switch.sh aerospace  # stop Rift, start AeroSpace
set -euo pipefail

case "${1:-}" in
  rift)
    osascript -e 'quit app "AeroSpace"' 2>/dev/null || true
    # Idempotent: registers the launchd agent if it is not there yet.
    rift service install 2>/dev/null || true
    rift service start
    echo "Rift started. Logs: /tmp/rift_$USER.err.log"
    ;;
  aerospace)
    rift service stop 2>/dev/null || true
    open -a AeroSpace
    echo "AeroSpace started."
    ;;
  *)
    echo "usage: $0 rift|aerospace" >&2
    exit 1
    ;;
esac
