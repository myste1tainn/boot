#!/bin/bash

OPTS_RELEASE="true"
OPTS_STRIP_PREFIX="false"
OPTS_PUSH="false"
OPTS_PUSH_TAGS="false"
OPTS_YES="false"

POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -p|--push) OPTS_PUSH="true"; shift ;;
        -t|--push-tags) OPTS_PUSH_TAGS="true"; shift ;;
        -b|--beta) OPTS_RELEASE="false"; shift ;;
        -s|--strip-prefix) OPTS_STRIP_PREFIX="true"; shift ;;
        -y|--yes) OPTS_YES="true"; shift ;;
        *) POSITIONAL+=("$1"); shift ;;
    esac
done
set -- "${POSITIONAL[@]}"

LOCATION=$(echo "${1:-z}" | tr '[:upper:]' '[:lower:]')  # default: patch

# REGEX for tag extraction
VALID_TAG_REGEX=\([^0-9]*\)\([0-9]\+\.[0-9]\+\.[0-9]\+\)\([-._]*.*\)
PREFIXED_TAG_REGEX_QUOTED='\([^0-9]\+\)\([0-9]\+\.[0-9]\+\.[0-9]\+\)\([-._]*.*\)'

function check_tag() {
    if [[ "$1" =~ $VALID_TAG_REGEX ]]; then return; fi
    echo >&2 "Invalid semver tag format: $1"
    exit 1
}

function to_lower() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

function find_latest_tag() {
    git tag --sort=-taggerdate | head -n 1
}

function find_biggest_tag() {
    git tag --sort=-v:refname | head -n 1
}

LATEST_TAG=$(find_latest_tag)
BIGGEST_TAG=$(find_biggest_tag)

if [[ "$OPTS_YES" == "false" && "$LATEST_TAG" != "$BIGGEST_TAG" ]]; then
    echo "Found two tags:"
    echo "1) Latest tag by date : $LATEST_TAG"
    echo "2) Highest semver tag : $BIGGEST_TAG"
    echo ""
    read -p "Which one to bump? [1=Latest, 2=Biggest] (default: 2): " CHOICE
    if [[ "$CHOICE" == "1" ]]; then
        TAG_TO_BUMP="$LATEST_TAG"
    else
        TAG_TO_BUMP="$BIGGEST_TAG"
    fi
else
    TAG_TO_BUMP="$BIGGEST_TAG"
fi

check_tag "$TAG_TO_BUMP"

echo "* Tag selected to bump             : $TAG_TO_BUMP"
echo "= Strip prefix                     : $OPTS_STRIP_PREFIX"
echo "= Strip suffix (release mode)      : $OPTS_RELEASE"
echo "= Push commit after tag            : $OPTS_PUSH"
echo "= Push tags after tag              : $OPTS_PUSH_TAGS"
echo ""

# Extract parts
if [[ "$TAG_TO_BUMP" =~ $VALID_TAG_REGEX ]]; then
    PRX_PART=$(echo "$TAG_TO_BUMP" | gsed "s/$PREFIXED_TAG_REGEX_QUOTED/\1/g")
    VER_PART=$(echo "$TAG_TO_BUMP" | gsed "s/$PREFIXED_TAG_REGEX_QUOTED/\2/g")
    SFX_PART=$(echo "$TAG_TO_BUMP" | gsed "s/$PREFIXED_TAG_REGEX_QUOTED/\3/g")
else
    VER_PART="$TAG_TO_BUMP"
fi

X=$(echo "$VER_PART" | cut -d. -f1)
Y=$(echo "$VER_PART" | cut -d. -f2)
Z=$(echo "$VER_PART" | cut -d. -f3)

case "$LOCATION" in
    x|major) NEW_TAG="$((X+1)).0.0" ;;
    y|minor) NEW_TAG="$X.$((Y+1)).0" ;;
    z|patch) NEW_TAG="$X.$Y.$((Z+1))" ;;
    *)
        echo >&2 "Unknown bump type: $LOCATION"
        exit 1
        ;;
esac

if [[ "$OPTS_STRIP_PREFIX" == "false" ]]; then
    NEW_TAG="${PRX_PART}${NEW_TAG}"
fi

if [[ "$OPTS_RELEASE" == "false" ]]; then
    NEW_TAG="${NEW_TAG}${SFX_PART}"
fi

check_tag "$NEW_TAG"
echo "* Bumped!                           : $TAG_TO_BUMP → $NEW_TAG"
echo ""

git tag -a "$NEW_TAG" -m "bump tag for releasing"
[ $? -ne 0 ] && exit 1

if [[ "$OPTS_PUSH" == "true" ]]; then
    git push || exit 1
fi

if [[ "$OPTS_PUSH_TAGS" == "true" ]]; then
    git push --tags || exit 1
fi

