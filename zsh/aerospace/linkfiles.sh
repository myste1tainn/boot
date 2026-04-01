#! /bin/bash

SCRIPT_PATH="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"

source "$SCRIPT_PATH/files.sh"

base_dir="$HOME"

rm -rf "$base_dir/aerospace-configs"
mkdir -p "$base_dir/aerospace-configs/layouts"

for FILE in ${FILES[@]}; do
    FILE_PATH="$SCRIPT_PATH/files/$FILE"
    LINK_PATH="${base_dir}/$FILE"
    echo 'ln '$FILE_PATH' '$LINK_PATH
    ln $FILE_PATH $LINK_PATH
done


