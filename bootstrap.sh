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
# BASH_SOURCE[0] is unset (or "-") when stdin is piped; detect that case.
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

# Ensure brew is on PATH for this session (handles both arm64 and x86_64)
for _prefix in /opt/homebrew /usr/local; do
  [[ -x "$_prefix/bin/brew" ]] && eval "$($_prefix/bin/brew shellenv)" && break
done

# ── Brew bundle (the fast part) ───────────────────────────────────────────────
log "Installing packages via Brewfile..."
brew bundle --file="$SCRIPT_DIR/Brewfile" --no-lock
ok "Packages installed"

# ── Tool configs ──────────────────────────────────────────────────────────────
for TOOL in git zsh tmux kitty aerospace hammperspoon macos; do
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
  sdk install java 21-zulu
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
luarocks install luafilesystem 2>/dev/null || true

# ─────────────────────────────────────────────────────────────────────────────
ok "Bootstrap complete! Open a new terminal to apply shell changes."
