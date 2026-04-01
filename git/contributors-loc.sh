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
ALL_ARGS=$@

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

for dir in $(ls .); do
    cd $dir &&
        for contrib in $(git contributors | awk '{print $NF}'); do
            if [ "$contrib" != "<>" ]; then
                if [ "$OPTS_TSV" = "true" ]; then
                    sep="\t"
                elif [ "$OPTS_CSV" = "true" ]; then
                    sep=","
                else
                    sep=" "
                fi
                echo "$contrib$sep$dir$sep$(git loc $contrib "$ALL_ARGS")";
            fi
        done &&
            cd ..;
done
