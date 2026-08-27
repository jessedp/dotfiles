#!/usr/bin/env bash
# SessionStart hook: (1) tell Claude which machine it is on, (2) quietly refresh synced memory.
# Must never fail or block: every step is timeout-guarded and errors are swallowed.
host=$(hostname 2>/dev/null)
ts=$(timeout 2 tailscale ip -4 2>/dev/null | head -1)
[ -x "$HOME/.claude-memory/bin/pull.sh" ] && timeout 8 "$HOME/.claude-memory/bin/pull.sh" >/dev/null 2>&1
inv="/opt/control-center/inventory.md"
if [ -r "$inv" ]; then invnote="$inv (git clone; pull before acting)"; else invnote="$inv on oddjob (not cloned here)"; fi
echo "Machine: ${host:-unknown}${ts:+ (tailscale $ts)}. Home-lab/device inventory: $invnote."
exit 0
