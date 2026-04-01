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
        *) POSITIONAL+=("$1"); shift ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters


SRC_BRANCH="$1"
if [ -z SRC_BRANCH ]; then
    echo "Missing required 1st argument, 'source branch name' please specify"
    exit 1
fi

BASELINE_COMMIT="$2"
if [ -z BASELINE_COMMIT ]; then
    echo "Missing required 2st argument, 'baseline commit' please specify"
    exit 1
fi

function debug() {
    if [ "$VERBOSE" = "true" ]; then
        MSG="$1"
        echo "[DEBUG]: $MSG"
    fi
}

SRC_BRANCH_BACKUP="${SRC_BRANCH}_backup"
echo "Step 1: Checking out branch = ${SRC_BRANCH}, creating backup ${SRC_BRANCH_BACKUP}"
git checkout "${SRC_BRANCH}"
git checkout -b "${SRC_BRANCH_BACKUP}"
git push -u origin "${SRC_BRANCH_BACKUP}"
echo "-- Step 1 DONE"
echo ""
echo ""

echo "Step 2: Moving branch = ${SRC_BRANCH} to new location = ${BASELINE_COMMIT}"
git checkout "${SRC_BRANCH}"
git reset --hard "${BASELINE_COMMIT}"
git push -f
if [ "$?" -ne 0 ]; then
    echo "!!! Failed to force push '${SRC_BRANCH}', while trying to setup the new baseline"
    echo "!!! Please resolve the failure reason and force push '${SRC_BRANCH}' again"
fi
