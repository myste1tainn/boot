#!/bin/bash 
#===============================================================================
#
#          FILE: all-merge.sh
# 
#         USAGE: ./all-merge.sh 
# 
#   DESCRIPTION: For the specified directory, merge 
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
OPTS_FROM_BRANCH=
OPTS_STASH="false"
OPTS_REBASE="false"
OPTS_DRY="false"
OPTS_PUSH="false"
OPTS_FLAT="false"

POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -b|--branch)
            OPTS_BRANCH="$2"
            shift # past argument
            shift # past value
            ;;
        -f|--from-branch)
            OPTS_FROM_BRANCH="$2"
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
        -d|--dry)
            OPTS_DRY="true"
            shift # past argument
            ;;
        -p|--push)
            OPTS_PUSH="true"
            shift # past argument
            ;;
        -l|--flat)
            OPTS_FLAT="true"
            shift # past argument
            ;;
        *)    # unknown option
            POSITIONAL+=("$1") # save it in an array for later
            shift # past argument
            ;;
    esac
done

target_dir=(${POSITIONAL[@]})

if [ -z "$target_dir" ]; then
    echo 'Exiting... missing 1st argument, `directory`';
    exit 1
fi

function is_not_dry() {
    if [ "$OPTS_DRY" == "false" ]; then
        return 0
    else
        echo "*DRY RUN"
        return 1
    fi
}

function run() {
    echo "Fetching, all, prune..."
    git fetch -ap;

    if [ "$OPTS_STASH" == "true" ]; then
        echo "Stashing..."
        git stash;
    fi

    code=$?
    if [ "$code" -ne 0 ]; then 
        return $code
    fi

    if [ -z "$OPTS_BRANCH" ]; then
        OPTS_BRANCH=$(git branch --show-current)
    fi

    if [ -z "$OPTS_FROM_BRANCH" ]; then
        OPTS_FROM_BRANCH=$(git branch --show-current)
    fi

    checkout_success=false
    if [ ! -z "$OPTS_BRANCH" ]; then
        echo "Checking out $OPTS_BRANCH..."
        is_not_dry && git checkout "$OPTS_BRANCH";
        code=$?
        if [ "$code" -ne 0 ]; then
            echo "Failed to checkout branch $OPTS_BRANCH"
            echo "Exiting..."
            return 101
        fi
    fi

    code=$?
    if [ "$code" -ne 0 ]; then 
        echo "error fetching, return code = $code"
        return $code
    fi

    if [ "$OPTS_REBASE" == "true" ]; then
        echo "REBASE"
        echo "Rebasing onto $OPTS_FROM_BRANCH..."
        is_not_dry && git merge --rebase $OPTS_FROM_BRANCH 
    else
        echo "MERGE"
        echo "Merging from $OPTS_FROM_BRANCH..."
        is_not_dry && git merge $OPTS_FROM_BRANCH 
    fi

    code=$?
    if [ "$code" -ne 0 ]; then 
        echo "error merging/rebasing, return code = $code"
        return $code
    fi

    if [[ "$OPTS_PUSH" == "true" ]]; then
        echo "Pushing..."
        is_not_dry && git push
    fi

    return $?
}

mkdir -p /tmp/scripts/git/all-merge
tmp_report_dir=/tmp/scripts/git/all-merge/report_dir.log
tmp_report_res=/tmp/scripts/git/all-merge/report_res.log
function print_report() {
    IFS=$'\n'
    report_dir=($(cat $tmp_report_dir))
    report_res=($(cat $tmp_report_res))
    # echo "dir = $temp_report_dir"
    max_padding=10
    for dir in "${report_dir[@]}" ; do
        c=$(echo $dir | wc -c)
        if [ $c -gt $max_padding ]; then 
            max_padding=$c
        fi
    done
    # echo "max_padding = $max_padding"
    max_padding=$(($max_padding + 10))

    for i in "${!report_dir[@]}" ; do
        d=${report_dir[$i]}
        r=${report_res[$i]}
        #echo "d = $d"
        #echo "r = $r"
        #printf '%s%*s%s\n' "$d" $(($max_padding - ${#d} - ${#r})) " " "$r"
        printf '%s%*s%s\n' "$d" $(($max_padding - ${#d})) " " "$r"
    done
    rm -rf $tmp_report_dir $tmp_report_res
}

declare -a pids;
ORANGE='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

function perform() {
    dir=$1
    if [[ "$(ls -a $dir | grep .git)" == *".git"* ]]; then
        cd $dir
        if [ $? -eq 0 ]; then
            (
            echo "###################################################################################"
            echo "running for dir = $dir"
            run 
            code=$?
            if [ "$OPTS_DRY" == "true" ]; then
                res="${ORANGE}DRY${NC}";
            else
                # echo "code = '$code'"
                case $code in
                    0) res=$(echo "${GREEN}SUCCESS${NC}");;
                    101) res=$(echo "${RED}FAILED${NC}: The branch $OPTS_BRANCH cannot be checked-out");;
                    *) res=$(echo "${RED}FAILED${NC}");;
                esac
            fi
            echo "-----------------------------------------------------------------------------------"
            echo ""
            echo ""
            echo "$dir" >> $tmp_report_dir
            echo "$res" >> $tmp_report_res
            ) &

            pids[${i}]=$!
            cd -;
        fi
    else
        echo "Skipping... $dir is not a directory, or is not a git directory"
    fi
}


echo "Collecting ellible directories..."
# NOTE: the .build/ directory comes from the Swift Package Manager and can contains the .git, but it is dettached
# which is why it's being filtered out here
dirs=$(find $target_dir | grep '\.git$' | grep -v '\.build/'); 
echo "Processing total of $(echo $dirs | wc -l) directories"
echo ""

for gitdir in ${dirs[*]}; do
    idir=$(dirname $gitdir)
    perform "$idir"
done

# wait for all pids
for pid in ${pids[*]}; do
    wait $pid
done

print_report
