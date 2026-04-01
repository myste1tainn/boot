#!/bin/bash 
#===============================================================================
#
#          FILE: all-bump-tag.sh
# 
#         USAGE: ./all-bump-tag.sh 
# 
#   DESCRIPTION: For the specified directory, bump-tag of the git dir 
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
OPTS_DRY="false"
OPTS_PUSH="false"
OPTS_PUSH_TAGS="false"
OPTS_FLAT="false"
OPTS_STRIP_PREFIX="false"
OPTS_RELEASE="true"
OPTS_POSITION="z"

POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -p|--push)
            OPTS_PUSH="true"
            shift # past argument
            ;;
        -t|--push-tags)
            OPTS_PUSH_TAGS="true"
            shift # past argument
            ;;
        -b|--beta)
            OPTS_RELEASE="false"
            shift # past argument
            ;;
        -s|--strip-prefix)
            OPTS_STRIP_PREFIX="true"
            shift # past argument
            ;;
        -l|--flat)
            OPTS_FLAT="true"
            shift # past argument
            ;;
        -d|--dry)
            OPTS_DRY="true"
            shift # past argument
            ;;
        -o|--position)
            OPTS_POSITION="$2"
            shift # past argument
            shift # past value
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
    t=$([ "$OPTS_PUSH_TAGS" == "true" ] && echo "-t" || echo "")
    p=$([ "$OPTS_PUSH" == "true" ] && echo "-p" || echo "")
    cmd="git bump-tag $t $p $OPTS_POSITION"
    echo "Running command = $cmd"
    pwd

    if [ "$OPTS_DRY" = "false" ]; then
        eval "$cmd"
        code=$?
        if [ "$code" -ne 0 ]; then
            return $code
        fi
    else
        echo "*DRY"
        return 0
    fi
}

mkdir -p /tmp/scripts/git/all-bump-tag
tmp_report_dir=/tmp/scripts/git/all-bump-tag/report_dir.log
tmp_report_res=/tmp/scripts/git/all-bump-tag/report_res.log
function print_report() {
    report_dir=($(cat $tmp_report_dir))
    report_res=($(cat $tmp_report_res))
    max_padding=10
    for dir in "${report_dir[@]}" ; do
        c=$(echo $dir | wc -c)
        if [ $c -gt $max_padding ]; then 
            max_padding=$c
        fi
    done
    max_padding=$(($max_padding + 20))

    for i in "${!report_dir[@]}" ; do
        d=${report_dir[$i]}
        r=${report_res[$i]}
        printf '%s%*s%s\n' "$d" $(($max_padding - ${#d} - ${#r})) " " "$r"
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
            (echo "running for dir = $dir"
            run 
            res=$([ $? -eq 0 ] && echo "${GREEN}SUCCESS${NC}" || echo "${RED}FAILED${NC}")
            if [ "$OPTS_DRY" == "true" ]; then
                res="${ORANGE}DRY${NC}";
            fi
            echo ""
            echo ""
            echo "$dir" >> $tmp_report_dir
            echo "$res" >> $tmp_report_res) &

            pids[${i}]=$!
            cd ..;
        fi
    else
        echo "Skipping... $dir is not a directory, or is not a git directory"
    fi
}


for idir in "${target_dir[@]}"; do
    if [[ "$OPTS_FLAT" == "true" ]]; then
        perform "$idir"
    else
        cd $idir
        if [ $? -eq 0 ]; then
            for dir in $(ls .); do
                perform "$dir"
            done
            cd ..;
        fi
    fi
done

# wait for all pids
for pid in ${pids[*]}; do
    wait $pid
done

print_report
