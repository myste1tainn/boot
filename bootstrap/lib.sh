#!/usr/bin/env bash
# Shared helpers for bootstrap.sh and the per-pane scripts in bootstrap/.

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok() { printf '\033[1;32m  ✓\033[0m %s\n' "$*"; }
skip() { printf '\033[1;33m  →\033[0m %s (already done)\n' "$*"; }
warn() { printf '\033[1;33m  !\033[0m %s\n' "$*"; }
fail() { printf '\033[1;31m  ✗\033[0m %s\n' "$*"; }

# Every pane script reports completion by writing its exit status to
# $BOOT_LOCK_DIR/<name>. bootstrap.sh waits for the files and reads the status,
# so a failed pane is reported as failed instead of silently counting as done.
mark_done() { # mark_done <name> <status>
    printf '%s\n' "$2" >"$BOOT_LOCK_DIR/$1"
}

# Block until the named panes have finished.
wait_for() { # wait_for <name>...
    local n
    for n in "$@"; do
        while [[ ! -f "$BOOT_LOCK_DIR/$n" ]]; do sleep 2; done
    done
}

# Block until the named panes finished AND all of them succeeded.
require_ok() { # require_ok <name>...
    wait_for "$@"
    local n
    for n in "$@"; do
        [[ "$(cat "$BOOT_LOCK_DIR/$n")" == "0" ]] || return 1
    done
}
