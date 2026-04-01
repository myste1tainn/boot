#!/bin/bash 
#===============================================================================
#
#          FILE: all-status.sh
# 
#         USAGE: ./all-status.sh 
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
    git status
    return $?
}

i=0;
cd $target_dir;
if [ $? -eq 0 ]; then
    echo "Collecting ellible directories..."
    # NOTE: the .build/ directory comes from the Swift Package Manager and can contains the .git, but it is dettached
    # which is why it's being filtered out here
    dirs=$(find . | grep '\.git$' | grep -v '\.build/'); 
    echo $dirs
    for gitdir in ${dirs[*]}; do
        dir=$(dirname $gitdir)
        cd $dir 
        if [ $? -eq 0 ]; then
            echo "##############################################"
            echo "running for dir = $dir"
            run 
            echo "----------------------------------------------"
            echo ""
            echo ""
            echo ""
            cd - > /dev/null;
        fi
    done
    cd - > /dev/null;
fi
