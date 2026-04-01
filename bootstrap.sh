#!/usr/bin/env bash
# Bootstrap a new macOS machine.
# Run directly:  bash bootstrap.sh
# One-shot curl: curl -fsSL https://raw.githubusercontent.com/USER/boot/main/bootstrap.sh | bash
set -euo pipefail

BOOT_DIR="${BOOT_DIR:-$HOME/.boot}"
BOOT_REPO="${BOOT_REPO:-https://github.com/arnonkeereena/boot.git}"

# ── Logging ──────────────────────────────────────────────────────────────────
log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m  ✓\033[0m %s\n' "$*"; }
skip() { printf '\033[1;33m  →\033[0m %s (already done)\n' "$*"; }

# ── When piped via curl | bash, clone the repo first then re-exec ─────────────
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]:-}")" 2>/dev/null && pwd -P || true)"
if [[ -z "$SCRIPT_DIR" || ! -f "$SCRIPT_DIR/Brewfile" ]]; then
  log "Cloning $BOOT_REPO → $BOOT_DIR"
  if [[ -d "$BOOT_DIR/.git" ]]; then
    git -C "$BOOT_DIR" pull --ff-only
  else
    git clone "$BOOT_REPO" "$BOOT_DIR"
  fi
  exec bash "$BOOT_DIR/bootstrap.sh"
fi

# ── Homebrew ─────────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  log "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

for _prefix in /opt/homebrew /usr/local; do
  [[ -x "$_prefix/bin/brew" ]] && eval "$($_prefix/bin/brew shellenv)" && break
done

# ── Step 1: tmux first (needed to parallelise the rest) ───────────────────────
log "Installing tmux and tmuxinator..."
brew install tmux tmuxinator
ok "tmux ready"

# ── Step 2: Parallel brew installs via tmux panes ─────────────────────────────
# Pane 0 → Brewfile   (CLI tools, build tools, runtimes — ~fast)
# Pane 1 → Brewfile.apps (GUI apps, fonts, Flutter — ~slow downloads)
#
# Lock files signal completion so the main shell can wait.
LOCK_FORMULAE="/tmp/.boot-formulae-$$"
LOCK_APPS="/tmp/.boot-apps-$$"
SESSION="boot-$$"

CMD_FORMULAE="brew bundle --file='$SCRIPT_DIR/Brewfile' --no-lock 2>&1 \
  | tee /tmp/brew-formulae.log; touch $LOCK_FORMULAE"
CMD_APPS="brew bundle --file='$SCRIPT_DIR/Brewfile.apps' --no-lock 2>&1 \
  | tee /tmp/brew-apps.log; touch $LOCK_APPS"

log "Starting parallel brew installs (tmux session: $SESSION)..."
tmux new-session  -d -s "$SESSION" -x 220 -y 50 -n "formulae"
tmux send-keys    -t "$SESSION:formulae" "$CMD_FORMULAE" Enter
tmux new-window   -t "$SESSION" -n "apps"
tmux send-keys    -t "$SESSION:apps"     "$CMD_APPS"     Enter
tmux select-window -t "$SESSION:formulae"

# Background watcher: detaches the tmux client once both panes finish,
# which causes the foreground attach below to return automatically.
(
  while [[ ! -f "$LOCK_FORMULAE" || ! -f "$LOCK_APPS" ]]; do sleep 2; done
  sleep 1  # brief pause so the user can see the completion state
  tmux detach-client -s "$SESSION" 2>/dev/null
) &

# Show live progress by attaching through /dev/tty.
# /dev/tty is the real terminal even when stdin is a pipe (curl | bash),
# so this works in all cases. Falls back to silent wait if no terminal exists
# (e.g. CI environments).
if [[ -n "${TMUX:-}" ]]; then
  # Already inside tmux — switch to the new session rather than nesting
  tmux switch-client -t "$SESSION" </dev/tty >/dev/tty 2>/dev/tty || true
elif [[ -e /dev/tty ]]; then
  # Direct run or curl | bash — attach via /dev/tty
  tmux attach-session -t "$SESSION" </dev/tty >/dev/tty 2>/dev/tty || true
else
  # No terminal at all (CI/non-interactive) — wait silently
  log "No terminal detected — waiting silently (tail /tmp/brew-formulae.log for progress)"
  while [[ ! -f "$LOCK_FORMULAE" || ! -f "$LOCK_APPS" ]]; do sleep 3; done
fi

rm -f "$LOCK_FORMULAE" "$LOCK_APPS"
ok "All packages installed"

# ── Step 3: Tool configs (sequential — fast, mostly symlinks) ─────────────────
for TOOL in git zsh tmux wezterm aerospace hammperspoon macos nvim; do
  SCRIPT="$SCRIPT_DIR/$TOOL/install.sh"
  if [[ -f "$SCRIPT" ]]; then
    log "Configuring $TOOL..."
    bash "$SCRIPT"
  fi
done

# ── SDKMan + Java ─────────────────────────────────────────────────────────────
if ! command -v sdk &>/dev/null; then
  log "Installing SDKMan..."
  curl -s "https://get.sdkman.io" | bash
  # shellcheck source=/dev/null
  source "$HOME/.sdkman/bin/sdkman-init.sh"
  sdk install java  # installs the current default LTS
else
  skip "SDKMan"
fi

# ── Rust ──────────────────────────────────────────────────────────────────────
if ! command -v rustup &>/dev/null; then
  log "Installing Rust..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
fi
# shellcheck source=/dev/null
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
rustup component add rust-analyzer rustfmt 2>/dev/null || true
cargo install --locked tree-sitter-cli 2>/dev/null || true
ok "Rust ready"

# ── Go tools ─────────────────────────────────────────────────────────────────
if command -v go &>/dev/null; then
  log "Installing Go tools..."
  go install github.com/go-delve/delve/cmd/dlv@latest
  go install gotest.tools/gotestsum@latest
  ok "Go tools installed"
fi

# ── npm globals ───────────────────────────────────────────────────────────────
log "Installing npm globals..."
npm install -g yarn prettier @prettier/plugin-xml
yarn global add prisma dotenv-cli
ok "npm globals installed"

# ── Python packages ───────────────────────────────────────────────────────────
log "Installing Python packages..."
pip3 install --quiet --upgrade diagrams virtualenv pymobiledevice3
ok "Python packages installed"

# ── Ruby gems ─────────────────────────────────────────────────────────────────
log "Installing Ruby gems..."
gem install xcodeproj
SDKROOT=$(xcrun --sdk macosx --show-sdk-path 2>/dev/null) gem install xcode-install || true
ok "Ruby gems installed"

# ── luarocks ──────────────────────────────────────────────────────────────────
# luafilesystem: general filesystem access for lua scripts
# jsregexp: required by luasnip for LSP snippet regex transformations
luarocks install luafilesystem 2>/dev/null || true
luarocks install jsregexp 2>/dev/null || true

# ── Containers & Kubernetes ───────────────────────────────────────────────────
# Podman requires a Linux VM on macOS — init and start it if not already done.
if command -v podman &>/dev/null; then
  log "Initialising Podman machine..."
  if ! podman machine list --format '{{.Name}}' 2>/dev/null | grep -q .; then
    podman machine init
    ok "Podman machine initialised"
  else
    skip "Podman machine"
  fi
  if ! podman machine list --format '{{.Running}}' 2>/dev/null | grep -q 'true'; then
    podman machine start
    ok "Podman machine started"
  else
    skip "Podman machine already running"
  fi
fi

# Set minikube to use podman as its driver.
if command -v minikube &>/dev/null; then
  log "Configuring minikube driver → podman..."
  minikube config set driver podman 2>/dev/null
  ok "minikube driver set to podman"
fi

# kind needs no machine init — clusters are created on demand via: kind create cluster

# ── Credentials ───────────────────────────────────────────────────────────────
SECRETS_FILE="$HOME/.config/boot/secrets.env"
mkdir -p "$(dirname "$SECRETS_FILE")"

log "Setting up credentials (stored in $SECRETS_FILE, not tracked by git)..."

read -r -p "  GitLab token (leave blank to skip): " _gitlab_token
if [[ -n "$_gitlab_token" ]]; then
  if grep -q '^export GITLAB_TOKEN=' "$SECRETS_FILE" 2>/dev/null; then
    sed -i '' "s|^export GITLAB_TOKEN=.*|export GITLAB_TOKEN=\"$_gitlab_token\"|" "$SECRETS_FILE"
  else
    echo "export GITLAB_TOKEN=\"$_gitlab_token\"" >> "$SECRETS_FILE"
  fi
  ok "GITLAB_TOKEN saved to $SECRETS_FILE"
fi

# ─────────────────────────────────────────────────────────────────────────────
ok "Bootstrap complete! Open a new terminal to apply shell changes."
