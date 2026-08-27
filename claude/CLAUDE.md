# Global preferences

This file is shared across machines via `~/.dotfiles/claude/` (dotbot-linked into `~/.claude/`).

## Machines — check `hostname` before assuming anything local

- **lehrer** — laptop, main workstation (Xorg). Dev copies of nbh_accela / atl_council.
- **oscar** — desktop, big cores+RAM, Tailscale exit node (Wayland). Home of atl_ledger and who_owns_atl data.
- **oddjob** — LXC on the `zazu` Proxmox host; "network brain" (Docker: daily-digest, homepage, uptime-kuma, home-assistant…). Inventory at `/opt/control-center`.
- **woa-1**, **ls2/lastseen2** — internet-facing VPS running production sites. Reach in read-only unless explicitly told to deploy. No GPU anywhere.

All hosts are on Tailscale and resolve by name; `~/.ssh/config` has the aliases. The home-lab operations repo (`jessedp/home-control-center`) is cloned at `/opt/control-center` on lehrer, oscar and oddjob: inventory is `inventory.md` + `inventory/<host>.md` there. **Start system/infra/network sessions from `/opt/control-center`** so they share one memory scope; pull before acting, push after editing.

## Atlanta public-data questions

For "look at the data and answer…" sessions across nbh_accela / atl_council / who_owns_atl / atl_ledger, **start from `~/projects/python/atl-data`** (cloned on lehrer and oscar): its `AGENTS.md` has the authority table (which instance is the truth) and `bin/q` queries any instance read-only over Tailscale.

## Memory conventions

- Auto-memory is synced between machines via `~/.claude-memory` (git). Any memory that is machine-specific must **name the host** ("lehrer=Xorg, oscar=Wayland"), never assume "this machine".
- Durable project facts (schemas, data locations, gotchas) belong in the repo (`AGENTS.md` / `docs/`), not in memory. Memory holds feedback, preferences, and pointers.
- `AGENTS.md` is the single instruction file per project; `CLAUDE.md`/`GEMINI.md` are symlinks to it. Never overwrite the symlinks.

## Bare image filenames = screenshots to read

If I paste just an image filename with no other context (e.g. `2026-07-14_18-12.png`,
`shot.jpg`), treat it as a screenshot I want you to look at. Don't ask what to do with
it — read it first, then respond to what's in it.

Resolve the path in this order, taking the first hit:
1. `~/Pictures/Screenshots/<name>`
2. `~/Downloads/<name>`
3. Current working directory

If it's in none of those, say so rather than guessing.
