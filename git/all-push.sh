#!/bin/bash 
#===============================================================================
#
#          FILE: all-push.sh
# 
#         USAGE: ./all-push.sh 
# 
#   DESCRIPTION: For the specified directory, pull update all the current branch
# 
#       OPTIONS: --target-branch={branch} (-b) When set, if comment and push will not be made if the current branch of the commit is not the specified
#                --stash (-s)           If specified, it will stash the change first before pull / checking out branches
#                --rebase (-r)          If specified, it will do `git pull --rebase` rather than just `git pull`
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: ARNON KEEREENA (a.keereena@gmail.com), 
#  ORGANIZATION: 
#       CREATED: 05/20/2022 14:52
#      REVISION:  ---
#===============================================================================

ALL_ARGS=$@
OPTS_PUSH=false
OPTS_UPSTREAM=false

POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -u|--set-upstream)
            OPTS_UPSTREAM=true
            shift # past argument
            shift # past value
            ;;
        -p|--push)
            OPTS_PUSH=true
            shift # past argument
            ;;
        *)    # unknown option
            POSITIONAL+=("$1") # save it in an array for later
            shift # past argument
            ;;
    esac
done

args_target_dir=${POSITIONAL[0]}

if [ -z "$args_target_dir" ]; then
    echo 'Exiting... missing 1st argument, `target_dir`';
    exit 1
fi

function run() {
    curr_dir=`pwd | awk -F '/' '{print $NF}'`
    if [ $OPTS_PUSH = true ]; then
        if [ $OPTS_UPSTREAM = true ]; then
            git push -u origin `git branch --show-current`;
        else
            git push
        fi

        code=$?
        if [ $? -eq 0 ]; then
            echo "[$curr_dir] Pushed, all ok"
        else
            echo "[$curr_dir] FAILED: canno push the commit to remote"
        fi
    fi

    if [ "$code" -ne 0 ]; then 
        return $code
    fi

    return 0
}

declare -a pids;
i=0;
cd $args_target_dir;
if [ $? -eq 0 ]; then
    echo "Collecting eligible directories..."
    # NOTE: the .build/ directory comes from the Swift Package Manager and can contains the .git, but it is dettached
    # which is why it's being filtered out here
    dirs=$(find . | grep '\.git$' | grep -v '\.build/'); 
    echo "Processing total of $(echo $dirs | wc -l) directories"
    echo ""
    tput sc;
    for gitdir in ${dirs[*]}; do
        tput ed;
        (
        dir=$(dirname $gitdir)
        cd $dir 
        if [ $? -eq 0 ]; then
            echo "running for dir = $dir"
            run 
            echo ""
            echo ""
            cd ..;
        fi
        ) &

        pids[${i}]=$!
        ((i=i+1))

        tput rc;
    done
    cd ..;
fi

for pid in ${pids[*]}; do
    wait $pid
done
