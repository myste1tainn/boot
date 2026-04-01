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
    'vimrc'
    'vimrcmain'
    'vimrcplug'
    'vimrc_settings_basic'
    'vimrc_functions'
    'ideavimrc'
)

OTHER_FILES=(
    'AnsiEsc.vba'
)

AFTER_FTPLUGIN_FILES=(
    'after/ftplugin/go.vim'
    'after/ftplugin/html.vim'
    'after/ftplugin/xml.vim'
)
