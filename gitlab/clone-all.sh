#!/bin/bash -
#===============================================================================
#
#          FILE: gitlab-clone-all.sh
#
#         USAGE: ./gitlab-clone-all.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (),
#  ORGANIZATION:
#       CREATED: 06/22/2023 20:26
#      REVISION:  ---
#===============================================================================

set -o nounset # Treat unset variables as an error

GROUP_ID=$1

GITLAB_TOKEN="${GITLAB_TOKEN:?GITLAB_TOKEN is not set — run bootstrap.sh or: export GITLAB_TOKEN=<your_token>}"
TOKEN="PRIVATE-TOKEN: ${GITLAB_TOKEN}"
PER_PAGE=50
URL="https://gitdev.devops.krungthai.com/api/v4/groups/${GROUP_ID}/projects?include_subgroups=true&per_page=${PER_PAGE}"

echo "Hitting API to get results of 1st page..."
curl -s --header "${TOKEN}" "${URL}" -v 2>/tmp/gitlab-clone-all-result.header 1>/tmp/gitlab-clone-all-result.body
echo "Done!"
echo ""

PAGE_COUNT=$(cat /tmp/gitlab-clone-all-result.header | grep '< x-total-pages:' | sed 's/< x-total-pages: //g' | sed 's/\r//g')
REPO_COUNT=$(cat /tmp/gitlab-clone-all-result.header | grep '< x-total:' | sed 's/< x-total: //g' | sed 's/\r//g')
REPO_SUCCESS=0
REPO_FAILED=0
echo "Cloning total of ${PAGE_COUNT} page of ${REPO_COUNT} repos"
echo ""

PARENT_DIR=${PWD##*/}

tput sc
for i in $(seq 1 $PAGE_COUNT); do
    tput ed
    echo "Cloning for page $i/${PAGE_COUNT}..."
    JSON=$(cat /tmp/gitlab-clone-all-result.body)

    for line in $(printf "%s" $JSON | jq -c ".[] | {repo:.http_url_to_repo,group:.namespace.name,name:.name}"); do
        name=$(echo "$line" | jq ".name " | tr -d '"')
        repo=$(echo "$line" | jq ".repo " | tr -d '"')
        group=$(echo $repo | sed "s/.*\/${PARENT_DIR}\///g" | sed 's/\(.*\)\/.*/\1/g')
        (
            if [[ "$group" == *.git ]]; then
                # it is a git directory under the PARENT_DIR, just clone
                git clone $repo >/dev/null 2>&1
            else
                # it is a subgroup (and maybe of another subgroup)
                # create the path first
                mkdir -p $group
                # go into it and clone
                cd $group && git clone $repo >/dev/null 2>&1
                cd ..
            fi
        ) &
        PIDS+=" $!"
        #(git clone $repo) &
    done

    #rm -rf /tmp/gitlab-clone-all-result.header
    #rm -rf /tmp/gitlab-clone-all-result.body

    if [[ $(($i - 1)) -eq $PAGE_COUNT ]]; then
        echo ""
        echo ""
        echo "Last page processed!"
        break 1
    else
        echo "Hitting API to get results of page $((i + 1))..."
        URL="https://gitdev.devops.krungthai.com/api/v4/groups/${GROUP_ID}/projects?include_subgroups=true&per_page=${PER_PAGE}&page=$((i + 1))"
        curl -s --header "${TOKEN}" "${URL}" -v 2>/tmp/gitlab-clone-all-result.header 1>/tmp/gitlab-clone-all-result.body
        tput rc
    fi
done

tput sc
for pid in $PIDS; do
    tput ed
    if wait $pid; then
        REPO_SUCCESS=$((REPO_SUCCESS + 1))
    else
        REPO_FAILED=$((REPO_FAILED + 1))
    fi
    echo "Done ${REPO_SUCCESS}/${REPO_COUNT}..."
    tput rc
done

echo ""
echo "Done!"
