#!/usr/bin/env bash
# Start Hammerspoon, Rift and Karabiner-Elements now and make each start at login.
# Idempotent. The macOS permission prompts (Accessibility, Input Monitoring, the
# Karabiner system extension) cannot be granted by a script; they appear on first launch.
set -uo pipefail
SCRIPT_DIR="$(cd -- "$(dirname "$0")" && pwd -P)"
source "$SCRIPT_DIR/lib.sh"

# ── Hammerspoon: login item + launch ─────────────────────────────────────────
if [[ -d /Applications/Hammerspoon.app ]]; then
    if osascript -e 'tell application "System Events" to get the name of every login item' 2>/dev/null | grep -q Hammerspoon; then
        skip "Hammerspoon login item"
    else
        osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Hammerspoon.app", hidden:true}' >/dev/null \
            && ok "Hammerspoon set to launch at login" || warn "Hammerspoon login item failed (allow Terminal to control System Events)"
    fi
    pgrep -x Hammerspoon >/dev/null && skip "Hammerspoon running" || { open -g -a Hammerspoon && ok "Hammerspoon started"; }
else
    warn "Hammerspoon.app not installed"
fi

# ── Rift: launchd service (RunAtLoad), AeroSpace stopped so they don't fight ──
if command -v rift >/dev/null; then
    bash "$SCRIPT_DIR/../rift/switch.sh" rift && ok "Rift service installed and started" || warn "Rift start failed — see /tmp/rift_$USER.err.log"
else
    warn "rift not installed"
fi

# ── Karabiner-Elements: the cask is a .pkg that needs your admin password ─────
if [[ ! -d /Applications/Karabiner-Elements.app ]]; then
    warn "Karabiner-Elements pkg never ran — reinstalling (enter your password if asked)"
    brew reinstall --cask karabiner-elements || warn "Karabiner reinstall failed"
fi
if [[ -d /Applications/Karabiner-Elements.app ]]; then
    # The pkg registers its own login agents; opening the app triggers the system-extension prompt.
    open -g -a Karabiner-Elements && ok "Karabiner-Elements started (approve its system extension + Input Monitoring)"
fi
