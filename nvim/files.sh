#!/bin/bash - 
#===============================================================================
#
#          FILE: files.sh
# 
#         USAGE: ./files.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 05/13/2022 23:07
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

FILES=(
    'vimrc_keymap_basic'
    'vimrc_keymap_lsp'
    'vimrc_keymap_telescope'
    'vimrc_keymap_coc_nvim'
    'vimrc_require_plugins'
    'vimrc_settings_vim_go'
)

OTHER_FILES=(
    'AnsiEsc.vba'
    'init.vim'
)

LUA_FILES=$(find $SCRIPT_PATH/lua -mindepth 1 | awk -F / '{print $(NF-1)"/"$(NF)}')

