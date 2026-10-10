#!/usr/bin/env bash
# SessionStart hook: (1) tell Claude which machine it is on, (2) quietly refresh synced memory,
# (3) warn when the memory sync on this host is stuck or its last run failed.
# Must never fail or block: every step is timeout-guarded and errors are swallowed.
host=$(hostname 2>/dev/null)
ts=$(timeout 2 tailscale ip -4 2>/dev/null | head -1)
mem="$HOME/.claude-memory"
[ -x "$mem/bin/pull.sh" ] && timeout 8 "$mem/bin/pull.sh" >/dev/null 2>&1
inv="/opt/control-center/inventory.md"
if [ -r "$inv" ]; then invnote="$inv (git clone; pull before acting)"; else invnote="$inv on oddjob (not cloned here)"; fi
echo "Machine: ${host:-unknown}${ts:+ (tailscale $ts)}. Home-lab/device inventory: $invnote."
warn=""
if [ -d "$mem/.git/rebase-merge" ] || [ -d "$mem/.git/rebase-apply" ] || [ -f "$mem/.git/MERGE_HEAD" ]; then
  warn="repo is mid-rebase/merge; run: cd ~/.claude-memory && git status"
elif [ -r "$mem/sync.log" ]; then
  last=$(tail -n 1 "$mem/sync.log" 2>/dev/null)
  case "$last" in *STUCK*|*CONFLICT*|*failed*) warn="last sync on this host: $last" ;; esac
fi
[ -n "$warn" ] && echo "MEMORY SYNC WARNING: $warn. Memory may be stale or diverged on ${host:-this host}; tell Jesse before relying on it."
exit 0
