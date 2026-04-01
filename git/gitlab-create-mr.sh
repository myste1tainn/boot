#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# git-create-mr  –  interactive wrapper around `glab mr create`
#
# Needs:
#   • glab (≥ 1.34)   brew install glab
#   • jq              brew install jq
#
# Features:
#   ▸ Detect CAMP-#### (or ANYKEY-####) in branch name
#   ▸ Or prompt “CAMP 123,124 or CAMP 10-12” and expand to links
#   ▸ Optional “Changes” list (- bullet list)
#   ▸ Optional “Coverage” (image path or raw text → fenced block)
#   ▸ Interactive reviewer / assignee lookup via glab API
#   ▸ Defaults: target branch = develop, squash + delete source
#   ▸ Opens MR edit page when done
# ---------------------------------------------------------------------------
set -euo pipefail

die() { printf >&2 "✖ %s\n" "$*"; exit 1; }
command -v glab >/dev/null || die "glab CLI is required."
command -v jq   >/dev/null || die "jq is required."

repo_root=$(git rev-parse --show-toplevel) || die "Not a git repo."
cd "$repo_root"
src_branch=$(git branch --show-current)

##############################################################################
# 1. gather tickets                                                          #
##############################################################################
ticket_regex='[A-Z_][A-Z0-9_]*-[0-9]\{1,\}'
tickets=()

if echo "$src_branch" | grep -Eq "$ticket_regex"; then
    while read -r t; do tickets+=("$t"); done \
        < <(echo "$src_branch" | grep -oE "$ticket_regex" | sort -u)
fi

if [[ ${#tickets[@]} -eq 0 ]]; then
    printf "Enter ticket(s) (e.g. CAMP 123,124 or CAMP 10-12): "
    read -r raw < /dev/tty
    raw=${raw//[[:space:]]/}
    key=${raw%%[0-9]*}  nums=${raw#"$key"}
    IFS=',' parts=()
    for seg in ${nums//,/ }; do
        if [[ $seg == *-* ]]; then
            IFS='-' read -r a b <<<"$seg"
            for ((i=a;i<=b;i++)); do parts+=("$i"); done
        else
            parts+=("$seg")
        fi
    done
    for n in "${parts[@]}"; do tickets+=("${key}${n}"); done
fi

##############################################################################
# 2. build MR body                                                           #
##############################################################################
body_tmp=$(mktemp)

{
    echo "# Tickets:"
    for t in "${tickets[@]}"; do
        echo "- [$t](https://ktbinnovation.atlassian.net/browse/$t)"
    done

    printf "\n# Changes:\n"
    while true; do
        read -r line < /dev/tty
        [[ -z $line ]] && break
        echo "- $line"
    done

    printf "\n# Coverage (optional)\n"
    read -r cov < /dev/tty
    if [[ -n $cov ]]; then
        if [[ -f $cov ]]; then
            md=$(glab api "/projects/$(glab repo view --json id -q .id)/uploads" \
                -F "file=@$cov" -q .markdown)
            echo "$md"
        else
            printf '```\n%s\n```\n' "$cov"
        fi
    fi
} >> "$body_tmp"

##############################################################################
# 3. reviewers / assignee helpers                                            #
##############################################################################
pick_user() {
    local prompt=$1
    while true; do
        printf "%s: " "$prompt" > /dev/tty
        read -r q < /dev/tty
        [[ -z $q ]] && { printf ""; return; }
        hits=$(glab api /users --paginate -q '.' --header '' -- -s "search=$q")
        mapfile -t lines < <(echo "$hits" | jq -r '.[]|"\(.id):\(.username) (\(.name))"')
        [[ ${#lines[@]} -eq 0 ]] && { echo "  no match" >&2; continue; }
        if [[ ${#lines[@]} -eq 1 ]]; then
            echo "${lines[0]%%:*}"; return
        fi
        printf "Matches:\n"; printf '  %s\n' "${lines[@]}"
        printf "Choose numeric ID: " > /dev/tty
        read -r id < /dev/tty
        for l in "${lines[@]}"; do [[ $l == "$id:"* ]] && { echo "$id"; return; } done
    done
}

reviewers=()
while true; do
    id=$(pick_user "Add reviewer (empty to stop)")
    [[ -z $id ]] && break
    reviewers+=("$id")
done

assignee=$(pick_user "Assignee (empty = you)")
[[ -z $assignee ]] && assignee=@me

##############################################################################
# 4. destination branch                                                      #
##############################################################################
printf "\nDestination branch (default: develop): " > /dev/tty
read -r dest < /dev/tty
dest=${dest:-develop}

##############################################################################
# 5. create MR via glab                                                      #
##############################################################################
title="${tickets[*]}: $(git log -1 --pretty=%s)"
glab mr create \
    --fill \
    --title "$title" \
    --description-file "$body_tmp" \
    --source-branch "$src_branch" \
    --target-branch "$dest" \
    --assignee "$assignee" \
    "${reviewers[@]/#/--reviewer }" \
    --squash --remove-source-branch -o json \
    | jq -r '.web_url' | {
    read -r url
    echo "✅ MR created: $url"
    (command -v open >/dev/null && open "$url/edit") || true
}

rm -f "$body_tmp"

