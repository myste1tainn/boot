#!/usr/bin/env bash
# Left pane 3: install GUI apps and fonts, then keep reminding the user what
# still has to be configured by hand until they say they are finished.
set -uo pipefail
SCRIPT_DIR="$(cd -- "$(dirname "$0")" && pwd -P)"
source "$SCRIPT_DIR/lib.sh"
export HOMEBREW_NO_AUTO_UPDATE=1

rc=0
log "[apps] Installing sign-in CLIs first (gh, glab, gcloud)..."
brew bundle --file="$SCRIPT_DIR/../Brewfile.cli-auth" 2>&1 | tee /tmp/brew-cli-auth.log
cli_rc=${PIPESTATUS[0]}
[[ $cli_rc -eq 0 ]] || rc=1
mark_done apps-cli "$cli_rc" # releases the long-running pane's gcloud step

log "[apps] Installing GUI apps (Brewfile.apps)..."
brew bundle --file="$SCRIPT_DIR/../Brewfile.apps" 2>&1 | tee /tmp/brew-apps.log
[[ ${PIPESTATUS[0]} -eq 0 ]] || rc=1

# brew bundle counts a cask as installed once its Caskroom folder exists, even if
# a .pkg installer inside it was cancelled or failed (e.g. the admin password
# prompt went unanswered) — the app is then missing but brew says "Using". For
# every pkg-based cask, check the installer receipt and reinstall if it is gone.
heal_pkg_casks() {
    local cask pkgid
    for cask in $(grep -E '^cask ' "$SCRIPT_DIR/../Brewfile.apps" | sed -E 's/^cask +["'"'"']([^"'"'"']+).*/\1/'); do
        pkgid=$(brew info --cask --json=v2 "$cask" 2>/dev/null \
            | jq -r '[.casks[0].artifacts[] | select(.uninstall) | .uninstall[].pkgutil // empty] | flatten | .[0] // empty')
        [[ -n "$pkgid" ]] || continue
        if ! pkgutil --pkg-info "$pkgid" &>/dev/null; then
            warn "[apps] $cask is in the Caskroom but its installer never ran — reinstalling (enter your password if asked)"
            brew reinstall --cask "$cask" || rc=1
        fi
    done
}
log "[apps] Checking pkg-based casks actually installed..."
heal_pkg_casks

log "[apps] Installing Nerd Fonts..."
bash "$SCRIPT_DIR/../fonts/install.sh" 2>&1 | tee /tmp/brew-fonts.log
[[ ${PIPESTATUS[0]} -eq 0 ]] || rc=1

if [[ $rc -eq 0 ]]; then ok "[apps] installed"; else fail "[apps] some installs failed — see /tmp/brew-apps.log /tmp/brew-fonts.log"; fi
mark_done apps-install "$rc"

# ── Barking ───────────────────────────────────────────────────────────────────
# Reprint the checklist every 45s until the user types "done". The checklist
# lists only apps and permissions that need a human; nothing here is automated.
checklist() {
    clear
    printf '\033[1;35m╔══ MANUAL SETUP — nothing below can be automated ══╗\033[0m\n\n'
    printf '\033[1mmacOS permissions (System Settings → Privacy & Security)\033[0m\n'
    cat <<'TXT'
  1. Karabiner-Elements : open it once, allow its system extension, grant
                          Input Monitoring. Config is linked by macos/install.sh.
  2. Hammerspoon        : grant Accessibility, enable "Launch at login".
  3. AeroSpace / Rift   : grant Accessibility when prompted.
  4. Alfred             : grant Accessibility + Full Disk Access; enter Powerpack
                          licence; set it to launch at login.
                          (Sync folder is set to ~/.alfred by alfred/install.sh.)

Sign in / activate
  5. Dropbox, Google Drive : sign in (Google Drive also asks for Full Disk Access).
  6. Brave                 : sign in to sync.
  7. Fantastical           : sign in / activate.
  8. Obsidian              : open your vault.
  9. Typora, CleanMyMac    : enter licences.
 10. ChatGPT, Claude       : sign in.
 11. Tunnelblick           : import your .ovpn configs, approve its helper tool.
 12. OpenVPN Connect       : import your profile; approve the network extension
                             / helper if macOS asks.
 13. WireGuard (GUI)       : install "WireGuard" from the Mac App Store (no cask).
                             The CLI (wg, wg-quick) comes from Brewfile.

CLI sign-ins
 14. gh auth login
 15. glab auth login --hostname <your GitLab host>
 16. gcloud auth login

TXT
    for _c in gh glab gcloud; do
        if command -v "$_c" &>/dev/null; then printf '  %-7s installed — ready to sign in\n' "$_c"
        else printf '  %-7s still installing...\n' "$_c"; fi
    done
    echo
    printf '\033[1;33mType "done" and press Enter once every item is finished.\033[0m\n'
    printf 'Install status — apps: %s\n' "$([[ $rc -eq 0 ]] && echo OK || echo FAILED)"
}

while true; do
    checklist
    if read -r -t 45 answer && [[ "$answer" == "done" ]]; then break; fi
done

ok "[apps] manual setup acknowledged"
mark_done apps-manual 0
