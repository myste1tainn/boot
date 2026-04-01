#!/bin/bash - 
#===============================================================================
#
#          FILE: linkfiles.sh
# 
#         USAGE: ./linkfiles.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: ARNON KEEREENA (a.keereena@gmail.com),
#  ORGANIZATION: 
#       CREATED: 05/13/2022 23:07
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source $SCRIPT_PATH/../scripts/helpers/link.sh

sh link-files.sh ~ "$(find $SCRIPT_PATH/home/dotfiles -type f)" --dotfiles
sh link-files.sh ~ "$(find $SCRIPT_PATH/home/ -type f -maxdepth 1)"
sh link-files.sh ~/.vim/after/ftplugin "$(find $SCRIPT_PATH/after/ftplugin -type f)"

mkdir -p ~/.vim/MySnips/
sh link-files.sh ~/.vim/MySnips "$(find $SCRIPT_PATH/MySnips -type f)"

