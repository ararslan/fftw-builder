#!/usr/bin/bash
# Based on code by Stefan Buck
# Usage: github-upload.sh ./file.zip

set -e

if [[ -z "$1" ]]; then
    echo "ERROR: No file provided"
    exit 1
fi
FILE="$1"

# CIRCLE_PROJECT_xxx are automatic environment variables set by CircleCI
REPO="https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME"

# Token read from private CircleCI variable set in the web UI
AUTH="Authorization: token $GH_AUTH_TOKEN"

RESPONSE=$(curl -sH "$AUTH" $REPO/releases/latest)

# Get release ID for the latest tag, save as variable `id`
eval $(echo "$RESPONSE" | grep -m 1 "id." | grep -w id | tr : = | tr -cd '[[:alnum:]]=')

if [[ -z "${id// }" ]]; then
    echo "ERROR: Failed to get release ID for tag"
    echo "$RESPONSE" | awk 'length($0)<100' >&2
    exit 1
fi

curl \
    -A "CircleCI $(curl --version | head -n 1)" \
    -H "Content-Type: application/zip" \
    -H "$AUTH" \
    -X POST \
    "$REPO/releases/$id/assets?name=$(basename $FILE)"
