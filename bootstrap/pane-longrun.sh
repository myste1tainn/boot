#!/usr/bin/env bash
# Right pane: slow installs — neovim (plugin sync, treesitter, mason LSPs), the
# GKE auth plugin, language toolchain extras and the Colima VM. Installs its own
# prerequisites (Brewfile.longrun) so it runs in parallel with the other panes.
set -uo pipefail
SCRIPT_DIR="$(cd -- "$(dirname "$0")" && pwd -P)"
BOOT_ROOT="$(dirname "$SCRIPT_DIR")"
source "$SCRIPT_DIR/lib.sh"

failures=()
step() { # step <label> <cmd...>
    local label="$1"; shift
    log "[long] $label"
    if "$@"; then ok "$label"; else fail "$label"; failures+=("$label"); fi
}

export HOMEBREW_NO_AUTO_UPDATE=1
log "[long] Installing this pane's own prerequisites (Brewfile.longrun)..."
step "brew bundle Brewfile.longrun" brew bundle --file="$BOOT_ROOT/Brewfile.longrun"

eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# ── Neovim ────────────────────────────────────────────────────────────────────
step "neovim (config, plugins, treesitter, mason)" bash "$BOOT_ROOT/nvim/install.sh"

# ── Rust ──────────────────────────────────────────────────────────────────────
step "rust components" rustup component add rust-analyzer rustfmt
step "tree-sitter-cli (cargo)" cargo install --locked tree-sitter-cli

# ── Go ────────────────────────────────────────────────────────────────────────
if command -v go &>/dev/null; then
    step "go: dlv" go install github.com/go-delve/delve/cmd/dlv@latest
    step "go: gotestsum" go install gotest.tools/gotestsum@latest
fi

# ── npm / yarn ────────────────────────────────────────────────────────────────
step "npm globals" npm install -g yarn prettier @prettier/plugin-xml
step "yarn globals" yarn global add prisma dotenv-cli

# ── Python (PEP 668: CLI tools via pipx, libraries into the user site) ────────
for _pkg in virtualenv pymobiledevice3; do
    step "pipx: $_pkg" bash -c "pipx list --short 2>/dev/null | grep -q '^$_pkg ' && pipx upgrade --quiet $_pkg || pipx install --quiet $_pkg"
done
step "pip: diagrams" python3 -m pip install --quiet --upgrade --user --break-system-packages diagrams

# ── Ruby ──────────────────────────────────────────────────────────────────────
step "gem: xcodeproj" gem install xcodeproj
step "gem: xcode-install" env SDKROOT="$(xcrun --sdk macosx --show-sdk-path 2>/dev/null)" gem install xcode-install

# ── luarocks (luafilesystem; jsregexp for luasnip) ────────────────────────────
step "luarocks: luafilesystem" luarocks install luafilesystem
step "luarocks: jsregexp" luarocks install jsregexp

# ── Containers: Colima VM + docker plugins + minikube driver ──────────────────
COLIMA_CPU="${COLIMA_CPU:-8}"; COLIMA_MEMORY="${COLIMA_MEMORY:-16}"; COLIMA_DISK="${COLIMA_DISK:-100}"
if command -v docker &>/dev/null; then
    mkdir -p "$HOME/.docker"
    if [[ ! -f "$HOME/.docker/config.json" ]]; then
        printf '{\n  "cliPluginsExtraDirs": [\n    "/opt/homebrew/lib/docker/cli-plugins"\n  ]\n}\n' >"$HOME/.docker/config.json"
        ok "docker cliPluginsExtraDirs written"
    elif ! grep -q cliPluginsExtraDirs "$HOME/.docker/config.json"; then
        warn "~/.docker/config.json lacks cliPluginsExtraDirs — add /opt/homebrew/lib/docker/cli-plugins manually"
    fi
fi
if command -v colima &>/dev/null; then
    if ! colima list --json 2>/dev/null | grep -q '"name":"default"'; then
        step "colima create+start" colima start --cpu "$COLIMA_CPU" --memory "$COLIMA_MEMORY" --disk "$COLIMA_DISK" --vm-type vz --vz-rosetta --mount-type virtiofs
    elif ! colima status &>/dev/null; then
        step "colima start" colima start
    else
        skip "colima"
    fi
fi
command -v minikube &>/dev/null && step "minikube driver=docker" minikube config set driver docker

# ── Google Cloud (installed by the apps pane; last so we rarely wait) ─────────
log "[long] Waiting for gcloud from the apps pane..."
if require_ok apps-cli; then
    step "gke-gcloud-auth-plugin" gcloud components install gke-gcloud-auth-plugin --quiet
else
    fail "gcloud was not installed by the apps pane"; failures+=("gke-gcloud-auth-plugin")
fi

# ── Summary ───────────────────────────────────────────────────────────────────
if [[ ${#failures[@]} -eq 0 ]]; then
    ok "[long] everything installed"; mark_done long 0
else
    fail "[long] ${#failures[@]} step(s) failed:"; printf '    - %s\n' "${failures[@]}"; mark_done long 1
fi
