#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "$0")" >/dev/null 2>&1; pwd -P)"

mkdir -p "$HOME/.config/rift"

while IFS= read -r FILE; do
  [[ -z "$FILE" ]] && continue
  ln -sf "$SCRIPT_DIR/files/$FILE" "$HOME/$FILE"
done < <(printf '%s\n' \
  ".config/rift/config.toml"
)
