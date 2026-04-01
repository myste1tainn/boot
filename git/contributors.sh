#!/bin/bash 
#===============================================================================
#
#          FILE: line-counts.sh
# 
#         USAGE: ./line-counts.sh 
# 
#   DESCRIPTION: Get name list of all contributors on a repo
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

OPTS_RELEASE="true"
OPTS_STRIP_PREFIX="false"
OPTS_PUSH="false"
OPTS_PUSH_TAGS="false"

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
        *)    # unknown option
            POSITIONAL+=("$1") # save it in an array for later
            shift # past argument
            ;;
    esac
done

set -- "${POSITIONAL[@]}" # restore positional parameters

git shortlog --summary --numbered --email

