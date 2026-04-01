#!/bin/bash 
#===============================================================================
#
#          FILE: line-counts.sh
# 
#         USAGE: ./line-counts.sh 
# 
#   DESCRIPTION: Get number of line counts done by the specified user, using regex search, partial matching
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: ARNON KEEREENA (a.keereena@gmail.com), 
#  ORGANIZATION: 
#       CREATED: 05/20/2022 14:52
#      REVISION:  ---
#===============================================================================

OPTS_TSV="false"
OPTS_CSV="false"

POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -p|--csv)
            OPTS_CSV="true"
            shift # past argument
            ;;
        -p|--tsv)
            OPTS_TSV="true"
            shift # past argument
            ;;
        *)    # unknown option
            POSITIONAL+=("$1") # save it in an array for later
            shift # past argument
            ;;
    esac
done

set -- "${POSITIONAL[@]}" # restore positional parameters

if [ "$OPTS_TSV" = "true" ]; then
    git log --author="$1" --pretty=tformat: --numstat | awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf "%s\t%s\t%s\n", add, subs, loc }' -
elif [ "$OPTS_CSV" = "true" ]; then
    git log --author="$1" --pretty=tformat: --numstat | awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf "%s,%s,%s\n", add, subs, loc }' -
else
    git log --author="$1" --pretty=tformat: --numstat | awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf "added lines: %s, removed lines: %s, total lines: %s\n", add, subs, loc }' -
fi

