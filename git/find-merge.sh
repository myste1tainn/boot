#!/bin/bash - 
#===============================================================================
#
#          FILE: find-merge.sh
# 
#         USAGE: ./find-merge.sh 
# 
#   DESCRIPTION: Find latest merge point that introduce the speicifed commit.
#                The findings uses HEAD as final location, thus if HEAD is on
#                a location that has no related history to the commit
#                The result will be empty
#                If the commit is merged several times, the latest one is
#                the results
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: ARNON KEEREENA (a.keereena@gmail.com), 
#  ORGANIZATION: 
#       CREATED: 05/21/2022 11:19
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

VERBOSE="false"

POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -v|--verbose) VERBOSE="true" shift ;;
        *) POSITIONAL+="$1" shift ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

commit=$1
branch=${2:-HEAD}

function debug() {
    if [ "$VERBOSE" = "true" ]; then
        MSG="$1"
        echo "[DEBUG]: $MSG"
    fi
}

rev_list_ancenstry_path=$(git rev-list $commit..$branch --ancestry-path | cat -n);
debug "Rev-list: ancestry-path = \n$rev_list_ancenstry_path\n"

rev_list_first_parent=$(git rev-list $commit..$branch --first-parent | cat -n)
debug "Rev-list: first-parent  = \n$rev_list_first_parent\n"

sorted=$((echo "$rev_list_ancenstry_path"; echo "$rev_list_first_parent") | sort -k2 -s)
debug "Sorted: = \n$sorted\n"

uniqed=$(echo "$sorted" | uniq -f1 -d | sort -n)
debug "Uniqed: = \n$uniqed\n"

## End result
debug "Result = "
echo "$uniqed" | tail -1 | cut -f2

