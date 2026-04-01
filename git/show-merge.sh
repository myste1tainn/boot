#!/bin/bash - 
#===============================================================================
#
#          FILE: show-merge.sh
# 
#         USAGE: ./show-merge.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: ARNON KEEREENA (a.keereena@gmail.com), 
#  ORGANIZATION: 
#       CREATED: 05/21/2022 12:06
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

merge=$(git find-merge "$@")
echo "$merge"
result=$(echo "$merge" | tail -n 1) 

if [ -n "$result" ]; then
    git show $result;
fi
