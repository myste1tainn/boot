#!/bin/bash
set -euo pipefail

BRANCH=${1}
TITLE=${2}
DESC=${3}

REMOTE=$(git remote get-url origin 2>/dev/null || echo "")

if [[ -z "$REMOTE" ]]; then
    echo "[ERROR] No Git remote found."
    exit 1
fi

echo "Remote: $REMOTE"
echo "Branch to merge: $BRANCH"
echo "Title: $TITLE"
echo "Description: $DESC"
echo ""

if [[ "$REMOTE" == *github.com* ]]; then
    echo "[GitHub] Creating PR..."
    gh pr create \
        --title "$TITLE" \
        --body "$DESC" \
        --base main \
        --head "$BRANCH" || echo "[ERROR] Failed to create PR"

elif [[ "$REMOTE" == *gitlab.com* ]]; then
    echo "[GitLab] Creating MR..."
    glab mr create \
        --title "$TITLE" \
        --description "$DESC" \
        --target-branch main \
        --source-branch "$BRANCH" || echo "[ERROR] Failed to create MR"

else
    echo "[ERROR] Unsupported remote host: $REMOTE"
    exit 1
fi
