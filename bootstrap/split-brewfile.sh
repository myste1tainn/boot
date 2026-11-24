#!/usr/bin/env bash
# Split a Brewfile into two halves of (almost) equal entry count so two panes
# can install in parallel. Entries alternate between halves so heavy and light
# packages spread out. Taps go into both halves (they are also tapped up front
# by bootstrap.sh, so the copy is a no-op).
# Usage: split-brewfile.sh <Brewfile> <out-a> <out-b>
set -euo pipefail
awk -v a="$2" -v b="$3" '
  /^tap /            { print > a; print > b; next }
  /^(brew|cask) /    { if (n++ % 2 == 0) print > a; else print > b }
' "$1"
