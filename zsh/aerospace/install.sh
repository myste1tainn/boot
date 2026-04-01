#! /bin/bash

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

source "$SCRIPT_PATH/files.sh"

brew install --cask nikitabobko/tap/aerospace

sh $SCRIPT_PATH/linkfiles.sh
