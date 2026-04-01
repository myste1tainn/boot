#!/bin/bash
#===============================================================================
#
#          FILE: all-sync.sh
#
#         USAGE: ./all-sync.sh
#
#   DESCRIPTION: For the specified directory, sync (git fetch -ap) all git directoy under it
#                with max-depth = 1
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

OPTS_CREATE_BRANCH=false
OPTS_PUSH=false
OPTS_STASH=false
POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
    -p | --push)
        OPTS_PUSH=true
        shift # past argument
        ;;
    -s | --stash)
        OPTS_STASH=true
        shift # past argument
        ;;
    -b | --branch)
        OPTS_CREATE_BRANCH=true
        shift # past argument
        ;;
    *)                     # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        shift              # past argument
        ;;
    esac
done

target_dir=${POSITIONAL[0]}
target_branch=${POSITIONAL[1]}

if [ -z "$target_dir" ]; then
    echo 'Exiting... missing 1st argument, `directory`'
    exit 1
fi

if [ -z "$target_branch" ]; then
    echo 'Exiting... missing 2nd argument, `branch`'
    exit 1
fi

declare -a pids
i=0
cd $target_dir

echo "Collecting ellible directories..."
# NOTE: the .build/ directory comes from the Swift Package Manager and can contains the .git, but it is dettached
# which is why it's being filtered out here
dirs=$(find . -type d -name ".git" | sed 's|/\.git||')
echo "Processing total of $(echo "$dirs" | wc -l) directories"
echo ""

tmp_report_dir=/tmp/scripts/git/all-checkout
tmp_report_res=${tmp_report_dir}/report_res.log
rm -rf "$tmp_report_res"
mkdir -p "$tmp_report_dir"
touch "$tmp_report_res"

declare -a res
for gitdir in ${dirs[*]}; do
    (
        cd $gitdir
        if [ $OPTS_STASH == "true" ]; then
            git stash
        fi
        if [ $OPTS_CREATE_BRANCH == "true" ]; then
            git checkout -b $target_branch
            if [ $OPTS_PUSH == "true" ]; then
                git push -u origin $target_branch
            fi
        else
            git checkout $target_branch
        fi
        res=$([ $? -eq 0 ] && echo "$gitdir SUCCESS" || echo "$gitdir FAILED")
        echo "$res" >>"$tmp_report_res"
        cd -
    ) &

    pids+=("$!")
done

# wait for all sub shell
for pid in ${pids[*]}; do
    wait $pid
done

cat "$tmp_report_res"
