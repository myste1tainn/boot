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
    'tmux.conf'
)

TMUXINATOR_FILES=$(find $SCRIPT_PATH/tmuxinator -mindepth 1 )

