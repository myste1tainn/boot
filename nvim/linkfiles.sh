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
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 05/13/2022 23:07
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source $SCRIPT_PATH/../scripts/helpers/link.sh

sh link-files.sh ~/.config/nvim "$(find $SCRIPT_PATH/home/dotfiles -type f)" --dotfiles
sh link-files.sh ~/.config/nvim "$(find $SCRIPT_PATH/home -type f -maxdepth 1)"

cmd="ln -s $SCRIPT_PATH/lua ~/.config/nvim"
echo $cmd
eval $cmd

cmd="ln -s $SCRIPT_PATH/ftplugin ~/.config/nvim"
echo $cmd
eval $cmd

cmd="ln -s $SCRIPT_PATH/after ~/.config/nvim"
echo $cmd
eval $cmd
