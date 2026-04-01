#!/bin/bash - 
#===============================================================================
#
#          FILE: history-branch.sh
# 
#         USAGE: ./history-branch.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: ARNON KEEREENA (a.keereena@gmail.com),
#  ORGANIZATION: 
#       CREATED: 05/21/2022 12:22
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

OPTS_ALL="false"

POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key=$1
    case $key in
        -a|--all) OPTS_ALL="true"; shift ;;
        *) POSITIONAL+=$1 shift ;;
    esac
done

if [ "${#POSITIONAL[@]}" -eq 0 ] || [ -z "$POSITIONAL" ]; then
    POSITIONAL=(10)
fi

set -- ${POSITIONAL[@]} # restore postional parameter

function to_lower() {
    STR=$1
    echo $STR | tr '[:upper:]' '[:lower:]'
}

N=${1:-10}

if [ $OPTS_ALL ]; then
    #CMD="git rev-parse --symbolic"
    CMD="git rev-parse --symbolic-full-name"
else
    CMD="git rev-parse --symbolic-full-name"
fi

(
for (( i=1; i<=$N; i++ )) do 
    result=$($CMD @{-$i} 2>/dev/null)
    status=$?
    if [ "$status" -ne 0 ]; then
        break
    fi
    #echo "$result" >> /tmp/history-branch.out
    echo "$result"
done
) | less - 
