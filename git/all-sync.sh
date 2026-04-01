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

POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
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

declare -a pids
cd $target_dir
if [ $? -eq 0 ]; then
    for dir in $(ls .); do
        (
        if [[ "$(ls -a $dir | grep .git)" == *".git"* ]]; then
            cd $dir 
            if [ $? -eq 0 ]; then
                git fetch -ap; cd ..;
            fi
        elif [[ -d $dir ]]; then
            git all-sync $dir;
        else
            echo "Skipping... $dir is neither directory nor git directory"
        fi
        ) &

        pids[${i}]=$!
    done
    cd ..;
fi

# wait for all pids
for pid in ${pids[*]}; do
    wait $pid
done
