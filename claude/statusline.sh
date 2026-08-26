#!/usr/bin/env bash
# Claude Code status line: model · dir · git branch · last-message time.
# Input: JSON on stdin with .model.display_name, .workspace.current_dir,
# and .transcript_path (this session's JSONL log).
# The timestamp is the arrival time of the most recent message in THIS
# session (read from the transcript), not the wall clock.

input=$(cat)

model=$(printf '%s' "$input" | jq -r '.model.display_name // .model.id // "?"')
dir=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // "."')
transcript=$(printf '%s' "$input" | jq -r '.transcript_path // empty')

# Shorten $HOME to ~ for display
pretty_dir=${dir/#$HOME/\~}

# Current git branch (empty if not in a repo)
branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)

# Last message timestamp from the session transcript (ISO-8601 UTC -> local).
stamp=""
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  iso=$(tail -n 1 "$transcript" | jq -r '.timestamp // empty' 2>/dev/null)
  [ -n "$iso" ] && stamp=$(date -d "$iso" '+%Y-%m-%d %H:%M:%S' 2>/dev/null)
fi

# \033[36m cyan · \033[33m yellow · \033[35m magenta · \033[2m dim · \033[0m reset
out=$(printf '\033[36m%s\033[0m \033[2m·\033[0m \033[33m%s\033[0m' "$model" "$pretty_dir")
[ -n "$branch" ] && out+=$(printf ' \033[2m·\033[0m \033[35m%s\033[0m' "$branch")
[ -n "$stamp" ]  && out+=$(printf ' \033[2m·\033[0m \033[2m%s\033[0m' "$stamp")

printf '%s' "$out"
