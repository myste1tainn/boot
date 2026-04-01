#!/bin/bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "Usage: clone-group.sh github|gitlab <org_or_group> [--visibility=public|private|all]"
    exit 1
fi

TYPE="$1"
GROUP="$2"
VISIBILITY="${3:-all}"

DEST="./"
mkdir -p "$DEST"
cd "$DEST"

if [[ "$TYPE" == "github" ]]; then
    gh repo list "$GROUP" --limit 1000 --json name,sshUrl,visibility |
    jq -r '.[] | select(.visibility == "'"$VISIBILITY"'" or "'"$VISIBILITY"'" == "all") | .sshUrl' |
    while read -r url; do
        echo "Cloning $url..."
        git clone "$url"
    done

elif [[ "$TYPE" == "gitlab" ]]; then
    clone_group() {
        local group="$1"
        local base_path="${2:-.}"
        echo "cloning for group: $group"

        PAGE=1
        while :; do
            RESULT=$(glab api "/groups/$group/projects?per_page=100&page=$PAGE" 2>/dev/null || echo "")
            echo "$RESULT" | jq -r '.[] | select(.visibility == "'"$VISIBILITY"'" or "'"$VISIBILITY"'" == "all") | @base64' |
            while read -r encoded; do
                _jq() { echo "$encoded" | base64 --decode | jq -r "$1"; }
                url=$(_jq '.http_url_to_repo')
                name=$(_jq '.path')

                mkdir -p "$base_path/"
                echo "Cloning $url into $base_path/$name ..."
                git clone "$url" "$base_path/$name" &
            done

            [[ $(echo "$RESULT" | jq length) -lt 100 ]] && break
            PAGE=$((PAGE + 1))
        done

        # Recursively process subgroups
        PAGE=1
        while :; do
            SUBGROUPS=$(glab api "/groups/$group/subgroups?per_page=100&page=$PAGE" 2>/dev/null || echo "")
            echo "$SUBGROUPS" | jq -r '.[] | [.id, .full_path] | @tsv' | while IFS=$'\t' read -r id full_path; do
                clone_group "$id" "$full_path"
            done
            [[ $(echo "$SUBGROUPS" | jq length) -lt 100 ]] && break
            PAGE=$((PAGE + 1))
        done
    }

    clone_group "$GROUP"
else
    echo "Unknown type: $TYPE. Use 'github' or 'gitlab'"
    exit 1
fi
