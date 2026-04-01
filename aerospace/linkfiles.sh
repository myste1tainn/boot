#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "$0")" >/dev/null 2>&1; pwd -P)"

mkdir -p "$HOME/aerospace-configs/layouts"

while IFS= read -r FILE; do
  [[ -z "$FILE" ]] && continue
  ln -sf "$SCRIPT_DIR/files/$FILE" "$HOME/$FILE"
done < <(printf '%s\n' \
  "aerospace-configs/layouts/qwerty.toml" \
  "aerospace-configs/layouts/dvorak.toml" \
  "aerospace-configs/base.toml"
)


