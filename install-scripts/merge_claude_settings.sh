#!/bin/bash
# install-scripts/merge_claude_settings.sh
#
# Merge the shared keys in claude/settings.base.json into this host's
# ~/.claude/settings.json. The live file is a plain per-host file (not a
# symlink), so /model, /config and per-host hooks can change it without
# dirtying the repo.
#
# Rules:
#   - Keys in the base win; keys only in the live file (model, effortLevel,
#     modelSettings, ...) are kept. Objects merge recursively, arrays from
#     the base replace the live ones.
#   - hooks: per event, the base entries come first, then any live entries
#     whose commands are not already in the base (host-only hooks survive).
#   - A key removed from the base is NOT removed from hosts; delete it by hand.
#
# Safe to re-run: writes only when the result differs, keeping one backup at
# ~/.claude/settings.json.bak.
set -euo pipefail

DOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BASE="$DOT/claude/settings.base.json"
LIVE="$HOME/.claude/settings.json"

echo "--- Merging shared Claude Code settings ---"
command -v jq &> /dev/null || { echo "ERROR: jq is required."; exit 1; }
mkdir -p "$HOME/.claude"

# One-time migration: settings.json used to be a dotbot symlink into this repo.
if [ -L "$LIVE" ]; then
    tmp=$(mktemp "$HOME/.claude/settings.json.XXXXXX")
    if [ -e "$LIVE" ]; then
        cat "$LIVE" > "$tmp"
    else
        # Dangling link: the repo copy was deleted by a pull. A pull only gets
        # that far when the host had no local edits, so the last committed
        # version is exactly what this host was using.
        sha=$(git -C "$DOT" log -1 --format=%H -- claude/settings.json)
        git -C "$DOT" show "${sha}^:claude/settings.json" > "$tmp"
    fi
    rm "$LIVE"
    mv "$tmp" "$LIVE"
    echo "INFO: Replaced the symlink with a per-host copy of its contents."
fi

[ -s "$LIVE" ] || echo '{}' > "$LIVE"
jq -e . "$LIVE" > /dev/null || { echo "ERROR: $LIVE is not valid JSON; fix it first."; exit 1; }
jq -e . "$BASE" > /dev/null || { echo "ERROR: $BASE is not valid JSON."; exit 1; }

merged=$(jq -n --slurpfile b "$BASE" --slurpfile l "$LIVE" '
  $b[0] as $base | $l[0] as $live
  | ($live * ($base | del(.hooks)))
  | if ($base.hooks // $live.hooks) == null then . else
      .hooks = ([($live.hooks // {} | keys[]), ($base.hooks // {} | keys[])] | unique
        | map(. as $ev
          | ($base.hooks[$ev] // []) as $be
          | [$be[].hooks[]?.command] as $bc
          | {key: $ev, value: ($be + [($live.hooks[$ev] // [])[]
              | select(any(.hooks[]?.command; IN($bc[])) | not)])})
        | from_entries)
    end')

if [ "$merged" == "$(jq . "$LIVE")" ]; then
    echo "SUCCESS: $LIVE already has the shared settings."
else
    cp -p "$LIVE" "$LIVE.bak"
    tmp=$(mktemp "$HOME/.claude/settings.json.XXXXXX")
    printf '%s\n' "$merged" > "$tmp"
    chmod --reference="$LIVE" "$tmp"
    mv "$tmp" "$LIVE"
    echo "SUCCESS: Merged shared settings into $LIVE (previous copy: $LIVE.bak)."
fi
echo "-------------------------------------------"
