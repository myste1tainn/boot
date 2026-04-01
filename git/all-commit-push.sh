#!/bin/bash 
#===============================================================================
#
#          FILE: all-pull.sh
# 
#         USAGE: ./all-pull.sh 
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

POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -b|--target-branch)
            OPTS_TARGET_BRANCH="$2"
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
args_msg=${POSITIONAL[1]}

if [ -z "$args_target_dir" ]; then
    echo 'Exiting... missing 1st argument, `target_dir`';
    exit 1
fi

if [ -z "$args_msg" ]; then
    echo 'Exiting... missing 2nd argument, `msg`';
    exit 1
fi

function run() {
    curr_dir=`pwd | awk -F '/' '{print $NF}'`
    if [ ! -z "$OPTS_TARGET_BRANCH" ]; then
        echo "[$curr_dir] HEAD must be on branch = $OPTS_TARGET_BRANCH..."
        curr_branch=$(git branch --show-current)

        if [[ "$curr_branch" = "$OPTS_TARGET_BRANCH" ]]; then
            echo "[$curr_dir] current branch ($curr_branch) matched with the specified ($OPTS_TARGET_BRANCH), proceeding..."
        else
            echo "[$curr_dir] FAILED: current branch ($curr_branch) is not the same as specified ($OPTS_TARGET_BRANCH), skipping..."
            return 1
        fi
    fi

    git add .
    git commit -m "$args_msg";
    if [ $OPTS_PUSH = true ]; then
        git push;
        if [ $? -eq 0 ]; then
            echo "[$curr_dir] Pushed, all ok"
        else
            echo "[$curr_dir] FAILED: canno push the commit to remote"
        fi
    fi

    code=$?
    if [ "$code" -ne 0 ]; then 
        return $code
    fi

    return $?
}

cd $args_target_dir;
if [ $? -eq 0 ]; then
    curr_dir=`pwd | awk -F '/' '{print $NF}'`
    for dir in $(ls .); do
        if [[ "$(ls -a $dir | grep .git)" == *".git"* ]]; then
            cd $dir 
            if [ $? -eq 0 ]; then
                run 
                cd ..;
            fi
        else
            echo "[$curr_dir] FAILED: Skipping... $dir is not a directory, or is not a git directory"
        fi
    done
    cd ..;
fi
