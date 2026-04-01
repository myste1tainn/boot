#!/bin/bash 
#===============================================================================
#
#          FILE: all-pull.sh
# 
#         USAGE: ./all-pull.sh 
# 
#   DESCRIPTION: For the specified directory, pull update all the current branch
# 
#       OPTIONS: --branch={branch} (-b) If specified, it will checkout the branch first then pull
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
OPTS_BRANCH=
OPTS_STASH="false"
OPTS_REBASE="false"

POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -b|--branch)
            OPTS_BRANCH="$2"
            shift # past argument
            shift # past value
            ;;
        -s|--stash)
            OPTS_STASH="true"
            shift # past argument
            ;;
        -r|--rebase)
            OPTS_REBASE="true"
            shift # past argument
            ;;
        *)    # unknown option
            POSITIONAL+=("$1") # save it in an array for later
            shift # past argument
            ;;
    esac
done

target_dir=${POSITIONAL[0]}

if [ -z "$target_dir" ]; then
    echo 'Exiting... missing 1st argument, `directory`';
    exit 1
fi

function run() {
    if [ "$OPTS_STASH" == "true" ]; then
        echo "Stashing..."
        git stash;
    fi

    code=$?
    if [ "$code" -ne 0 ]; then 
        return $code
    fi

    if [ ! -z "$OPTS_BRANCH" ]; then
        echo "Checking out $OPTS_BRANCH..."
        git checkout "$OPTS_BRANCH";
    fi

    # Should add the code to HALT when checkout fail
    #code=$?
    #if [ "$code" -ne 0 ]; then 
    #    return $code
    #fi

    if [ "$OPTS_REBASE" = "true" ]; then
        echo "Pull REBASE"
        git pull --rebase
    else
        echo "Pull MERGE"
        git pull
    fi

    return $?
}

declare -a pids;
i=0;
cd $target_dir;
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
