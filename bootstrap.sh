#!/usr/bin/env bash
# Bootstrap a new macOS machine.
# Run directly:  bash bootstrap.sh
# One-shot curl: curl -fsSL https://raw.githubusercontent.com/myste1tainn/boot/main/bootstrap.sh | bash
set -euo pipefail

BOOT_DIR="${BOOT_DIR:-$HOME/.boot}"
BOOT_REPO="${BOOT_REPO:-https://github.com/myste1tainn/boot.git}"

# ── Logging ──────────────────────────────────────────────────────────────────
log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok() { printf '\033[1;32m  ✓\033[0m %s\n' "$*"; }
skip() { printf '\033[1;33m  →\033[0m %s (already done)\n' "$*"; }
warn() { printf '\033[1;33m  !\033[0m %s\n' "$*"; }

# ── When piped via curl | bash, clone the repo first then re-exec ─────────────
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]:-}")" 2>/dev/null && pwd -P || true)"
if [[ -z "$SCRIPT_DIR" || ! -f "$SCRIPT_DIR/Brewfile" ]]; then
    log "Cloning $BOOT_REPO → $BOOT_DIR"
    if [[ -d "$BOOT_DIR/.git" ]]; then
        git -C "$BOOT_DIR" pull --ff-only
    else
        git clone "$BOOT_REPO" "$BOOT_DIR"
    fi
    git -C "$BOOT_DIR" submodule update --init --recursive
    exec bash "$BOOT_DIR/bootstrap.sh"
fi

source "$SCRIPT_DIR/bootstrap/lib.sh"

# ── Phase 1: package managers ─────────────────────────────────────────────────
# Everything the panes install with must exist first: brew, npm/pnpm (node),
# pip/pipx (python), gem (ruby), go, luarocks and cargo (rustup).
if ! command -v brew &>/dev/null; then
    log "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
for _prefix in /opt/homebrew /usr/local; do
    [[ -x "$_prefix/bin/brew" ]] && eval "$($_prefix/bin/brew shellenv)" && break
done

sudo xcodebuild -license accept

log "Updating Homebrew once (panes run with auto-update off to avoid lock fights)..."
brew update
# Tap up front so the parallel panes never race to clone the same tap.
# Recent Homebrew refuses to load formulae from untrusted third-party taps, so
# trust exactly the taps this repo's Brewfile declares (nothing else).
grep -E "^tap " "$SCRIPT_DIR/Brewfile" | while read -r _ _t; do
    _t="${_t//[\"\']/}"
    brew tap "$_t"
    brew trust --tap "$_t"
done

log "Installing package managers..."
brew install bash ruby node pnpm python3 pipx go luarocks
brew link --force ruby 2>/dev/null || true
brew link --force bash 2>/dev/null || true
# cargo/rustup come from rustup.rs, NOT brew: the brew rustup formula is keg-only,
# conflicts with the `rust` formula in the Brewfile and no longer ships rustup-init.
if [[ ! -x "$HOME/.cargo/bin/rustup" ]]; then
    log "Installing rustup (rustup.rs)..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
        | RUSTUP_INIT_SKIP_PATH_CHECK=yes sh -s -- -y --no-modify-path
fi
ok "Package managers ready"

# ── Phase 2: tmux + tmuxinator ────────────────────────────────────────────────
log "Installing tmux and tmuxinator..."
brew install tmux tmuxinator
ok "tmux ready"

# ── Phase 3: one tmux session, four panes ─────────────────────────────────────
#   ┌───────────────┬───────────────┐
#   │ formulae-a    │               │  left 1+2: the Brewfile split half-half
#   ├───────────────┤   long-run    │  left 3  : GUI apps + fonts, then keeps
#   │ formulae-b    │  (neovim,     │            reminding you what to configure
#   ├───────────────┤   gke plugin, │  right   : slow installs; installs its own
#   │ apps + manual │   toolchains) │            prerequisites, no waiting
#   └───────────────┴───────────────┘
# Completion is reported through files in $BOOT_LOCK_DIR holding each pane's
# exit status.
export BOOT_LOCK_DIR="/tmp/.boot-$$"
rm -rf "$BOOT_LOCK_DIR" && mkdir -p "$BOOT_LOCK_DIR"
SESSION="boot-$$"
HALF_A="$BOOT_LOCK_DIR/Brewfile.a"
HALF_B="$BOOT_LOCK_DIR/Brewfile.b"
bash "$SCRIPT_DIR/bootstrap/split-brewfile.sh" "$SCRIPT_DIR/Brewfile" "$HALF_A" "$HALF_B"

P="$SCRIPT_DIR/bootstrap"
ENVSET="export BOOT_LOCK_DIR='$BOOT_LOCK_DIR';"

tmux new-session -d -s "$SESSION" -x 220 -y 50 -n boot
# Right pane (the long-running one) takes 50% of the width; the left column is
# then cut into three equal stacks.
tmux split-window -h -t "$SESSION:boot.0" -l 50%
tmux split-window -v -t "$SESSION:boot.0" -l 66%
tmux split-window -v -t "$SESSION:boot.1" -l 50%
# Pane indexes now: 0 = left top, 1 = left middle, 2 = left bottom, 3 = right.
tmux send-keys -t "$SESSION:boot.0" "$ENVSET bash '$P/pane-formulae.sh' formulae-a '$HALF_A'" Enter
tmux send-keys -t "$SESSION:boot.1" "$ENVSET bash '$P/pane-formulae.sh' formulae-b '$HALF_B'" Enter
tmux send-keys -t "$SESSION:boot.2" "$ENVSET bash '$P/pane-apps.sh'" Enter
tmux send-keys -t "$SESSION:boot.3" "$ENVSET bash '$P/pane-longrun.sh'" Enter
tmux select-pane -t "$SESSION:boot.2"
log "Started tmux session $SESSION"

ALL_PANES=(formulae-a formulae-b apps-install apps-manual long)
all_done() { local n; for n in "${ALL_PANES[@]}"; do [[ -f "$BOOT_LOCK_DIR/$n" ]] || return 1; done; }

# Detach the client once every pane has reported, so the attach below returns.
(
    while ! all_done; do sleep 2; done
    sleep 1
    tmux detach-client -s "$SESSION" 2>/dev/null
) &

# Attach to the session. Redirecting stdin from /dev/tty makes tmux see its tty
# as "/dev/tty" and refuse ("can't use /dev/tty"), so only redirect when stdin is
# NOT a terminal (curl | bash), and then point at the real tty device.
attach_session() {
    if [[ -n "${TMUX:-}" ]]; then
        tmux switch-client -t "$SESSION"
    elif [[ -t 0 && -t 1 ]]; then
        tmux attach-session -t "$SESSION"
    else
        local _tty
        _tty="$(ps -o tty= -p $$ | tr -d ' ')"
        [[ -n "$_tty" && "$_tty" != "??" && -c "/dev/$_tty" ]] || return 1
        tmux attach-session -t "$SESSION" <"/dev/$_tty" >"/dev/$_tty" 2>"/dev/$_tty"
    fi
}

if ! attach_session; then
    warn "Could not attach a terminal. The installs keep running in tmux session $SESSION"
    warn "  watch them with:  tmux attach -t $SESSION   (answer any password prompt there)"
fi
# switch-client and a failed attach return immediately; wait for the panes.
# A manual detach also lands here, which is fine — it just keeps waiting.
while ! all_done; do sleep 3; done

# ── Report real pane results ──────────────────────────────────────────────────
_bad=0
for _n in "${ALL_PANES[@]}"; do
    _rc="$(cat "$BOOT_LOCK_DIR/$_n")"
    if [[ "$_rc" == "0" ]]; then ok "$_n"; else fail "$_n (exit $_rc)"; _bad=1; fi
done
rm -rf "$BOOT_LOCK_DIR"
[[ $_bad -eq 0 ]] || warn "Some panes failed — logs: /tmp/brew-*.log. Continuing to config."

# ── Phase 4: submodules and configs (fast, mostly symlinks) ───────────────────
log "Initialising git submodules..."
git -C "$SCRIPT_DIR" submodule update --init --recursive
ok "Submodules ready"

# nvim is configured by the long-running pane, not here.
for TOOL in git zsh tmux wezterm cmux aerospace rift hammperspoon alfred neovide macos dotclaude; do
    SCRIPT="$SCRIPT_DIR/$TOOL/install.sh"
    if [[ -f "$SCRIPT" ]]; then
        log "Configuring $TOOL..."
        bash "$SCRIPT"
    fi
done

# Start the window/keyboard tools and make them launch at login.
log "Starting Hammerspoon, Rift, Karabiner-Elements..."
bash "$SCRIPT_DIR/bootstrap/start-apps.sh" || warn "start-apps.sh reported problems"

# ── Credentials ───────────────────────────────────────────────────────────────
SECRETS_FILE="$HOME/.config/boot/secrets.env"
mkdir -p "$(dirname "$SECRETS_FILE")"

log "Setting up credentials (stored in $SECRETS_FILE, not tracked by git)..."

read -r -p "  GitLab token (leave blank to skip): " _gitlab_token
if [[ -n "$_gitlab_token" ]]; then
    if grep -q '^export GITLAB_TOKEN=' "$SECRETS_FILE" 2>/dev/null; then
        sed -i '' "s|^export GITLAB_TOKEN=.*|export GITLAB_TOKEN=\"$_gitlab_token\"|" "$SECRETS_FILE"
    else
        echo "export GITLAB_TOKEN=\"$_gitlab_token\"" >>"$SECRETS_FILE"
    fi
    ok "GITLAB_TOKEN saved to $SECRETS_FILE"
fi

# ─────────────────────────────────────────────────────────────────────────────
ok "Bootstrap complete! Open a new terminal to apply shell changes."
