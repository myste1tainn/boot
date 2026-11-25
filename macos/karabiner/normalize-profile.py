#!/usr/bin/env python3
"""git clean filter for karabiner.json: pin which profile is `selected`.

Hammerspoon (and the Karabiner UI) flips "selected" between profiles on the live
file, which is symlinked into this repo, so git would show a diff on every switch.
The filter rewrites the flags to a fixed profile only for git's comparison/staging;
the file on disk is never touched. Output is byte-identical to Karabiner's compact
format (no spaces, "/" escaped as "\\/", no trailing newline).
"""
import json
import sys

CANONICAL = "QWERTY Generated Profile"

raw = sys.stdin.read()
try:
    data = json.loads(raw)
    profiles = data["profiles"]
except (ValueError, KeyError, TypeError):
    sys.stdout.write(raw)  # not the expected shape: pass through untouched
    sys.exit(0)

if any(p.get("name") == CANONICAL for p in profiles):
    for p in profiles:
        p["selected"] = p.get("name") == CANONICAL

out = json.dumps(data, separators=(",", ":"), ensure_ascii=False).replace("/", "\\/")
sys.stdout.write(out + ("\n" if raw.endswith("\n") else ""))
