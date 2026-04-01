gitlab_token="REDACTED_GITLAB_TOKEN"

VERBOSE="false"
REMOVE_SOURCE_BRANCH="false"
DESCRIPTION=""

declare -a POSITIONAL
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
      -d|--remove-source-branch) REMOVE_SOURCE_BRANCH="true" shift ;;
      -v|--verbose) VERBOSE="true" shift ;;
      *) POSITIONAL+=("$1"); shift ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

PROJ_NAME="${POSITIONAL[0]}"
if [ -z $PROJ_NAME ]; then
    echo "Missing required 1st argument, 'source branch name' please specify"
    exit 1
fi

SRC_BRANCH="${POSITIONAL[1]}"
if [ -z $SRC_BRANCH ]; then
    echo "Missing required 2nd argument, 'source branch name' please specify"
    exit 1
fi

DST_BRANCH="${POSITIONAL[2]}"
if [ -z $DST_BRANCH ]; then
    echo "Missing required 3rd argument, 'baseline commit' please specify"
    exit 1
fi

TITLE="${POSITIONAL[3]}"
if [ -z "${TITLE}" ]; then
    echo "Missing required 4th argument, 'MR title' please specify"
    exit 1
fi

function debug() {
    if [ "$VERBOSE" = "true" ]; then
        MSG="$1"
        echo "[DEBUG]: $MSG"
    fi
}


find_proj_id () {
    out=$(curl --header "PRIVATE-TOKEN: $gitlab_token" --GET "https://gitdev.devops.krungthai.com/api/v4/groups/41/projects?search=$1&include_subgroups=true" -s | jq "map(select(.name == \"${1}\")) | .[0]")
    id=$(echo $out | jq '.id')
}

create_mr () {
    find_proj_id "${PROJ_NAME}"
    payload='{
  "source_branch": "'"${SRC_BRANCH}"'",
  "target_branch": "'"${DST_BRANCH}"'",
  "title": "'"${TITLE}"'",
  "description": "'"${DESCRIPTION}"'",
  "remove_source_branch": '"${REMOVE_SOURCE_BRANCH}"'
}'
echo $payload
    curl \
      --header "Content-Type: application/json" \
      -X POST \
      --header "PRIVATE-TOKEN: $gitlab_token" \
      --X "https://gitdev.devops.krungthai.com/api/v4/projects/$id/merge_requests" \
      -d "$payload" \
  -s | jq '.web_url'
}

create_mr
