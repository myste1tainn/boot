#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "$0")" >/dev/null 2>&1; pwd -P)"

mkdir -p "$HOME/.config/ghostty" "$HOME/.config/cmux" \
         "$HOME/.vim/ftdetect" "$HOME/.vim/ftplugin" "$HOME/.vim/syntax"

while IFS= read -r FILE; do
  [[ -z "$FILE" ]] && continue
  ln -sf "$SCRIPT_DIR/files/$FILE" "$HOME/$FILE"
done < <(printf '%s\n' \
  ".config/ghostty/config" \
  ".config/cmux/settings.json" \
  ".config/cmux/cmux.json" \
  ".vim/ftdetect/ghostty.vim" \
  ".vim/ftplugin/ghostty.vim" \
  ".vim/syntax/ghostty.vim"
)
