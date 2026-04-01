#!/bin/bash
set -euo pipefail

REMOTE=$(git remote get-url origin 2>/dev/null || echo "")

if [[ -z "$REMOTE" ]]; then
    echo "No remote configured."
    exit 1
fi

echo "Remote: $REMOTE"

if [[ "$REMOTE" == *gitlab.com* ]]; then
    echo "[Pipeline: GitLab]"
    glab pipeline status || echo "[Error] Failed to fetch pipeline status."
elif [[ "$REMOTE" == *github.com* ]]; then
    echo "[Actions: GitHub]"
    gh run list --limit 1 || echo "[Error] Failed to fetch GitHub Actions run."
else
    echo "Unknown or unsupported remote host."
    exit 1
fi
