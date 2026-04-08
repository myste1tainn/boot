#!/usr/bin/env bash
set -euo pipefail

brew install neovim

SCRIPT_DIR="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"
REPO="git@github.com:myste1tainn/dotfiles-nvim.git"
DEST="$HOME/.config/nvim"

mkdir -p "$HOME/.config"

# ── Clone or update config ────────────────────────────────────────────────────
if [[ -d "$DEST/.git" ]]; then
    git -C "$DEST" pull --ff-only
else
    git clone "$REPO" "$DEST"
fi

if command -v pipx &>/dev/null; then
    echo "pipx is already installed."
else
    echo "Installing pipx..."
    brew install pipx
fi

# pynvim required by many nvim plugins
if pipx list | grep -q "pynvim"; then
    pipx install --quiet pynvim
else
    pipx upgrade --quiet pynvim
fi

log() { printf '\033[1;34m  [nvim]\033[0m %s\n' "$*"; }

# ── 1. Install / sync all lazy.nvim plugins ───────────────────────────────────
log "Syncing plugins (lazy.nvim)..."
nvim --headless "+Lazy! sync" +qa 2>&1

# ── 2. Install treesitter parsers ─────────────────────────────────────────────
# All filetypes in use: dart go groovy java javascript lua python ruby rust starlark xml
log "Installing treesitter parsers..."
nvim --headless \
    -c "Lazy! load nvim-treesitter" \
    -c "TSInstall! go dart groovy java javascript lua python ruby rust starlark xml" \
    -c "qa" 2>&1

# ── 3. Install LSP servers via mason ─────────────────────────────────────────
# Servers: gopls pyright typescript-language-server rust-analyzer
#          jdtls groovy-language-server ruby-lsp lemminx
# (dart → bundled with Flutter SDK; lua → Homebrew; starlark → no mason package)
log "Installing LSP servers (mason)..."
nvim --headless \
    -c "Lazy! load mason.nvim" \
    -c "luafile $SCRIPT_DIR/mason_headless.lua" 2>&1

log "Ready."
