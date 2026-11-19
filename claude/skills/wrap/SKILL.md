---
name: wrap
description: Close out the current session safely. Use when the user types /wrap or says they want to wrap up, close, or finish a session. Saves anything durable that only exists in this conversation, then prints and records how to find the session again.
---

# Wrap up this session

Goal: the user can close this session without losing anything. Be brief; this is a checklist, not a report.

1. **Find what's unsaved.** Scan this conversation for durable things that exist only in chat or the scratchpad: findings, probe results, numbers, dates, decisions, drafts, open questions, next steps. Skip anything already written to a file, committed, or trivially re-derivable.
2. **Show the list** as one line per item, each with its proposed destination, following the global CLAUDE.md "Save findings as you go" targets (atl-data authority table, `~/projects/python/atl-reports/<topic>/`, `/mnt/Public/backups/web-archive/`, `/opt/control-center/inventory/<host>.md`, the repo's `AGENTS.md`/`docs/`, or memory for feedback/preferences). If nothing is unsaved, say so in one line and skip to step 4.
3. **Ask once** ("Save all? / pick numbers / skip"), then write them. Commit and push only in repos where this session already committed or the user asks.
4. **Print the handle**, exactly:
   - Session ID, launch directory (`pwd` at start), and `claude --resume <id>` run from that directory.
   - One line: what's done, and the single next step if any.
   - If the session drifted into several topics or was launched from the wrong tree, name that in one line so the user knows where the pieces went.
5. **Record the handle** so the project scanner can list open next steps without reading transcripts: `python3 ~/.claude/skills/wrap/record.py add --session <id> --cwd <launch directory> --topic "<2-5 words naming the piece of work>" --done "<what's done>" --next "<the single next step>" --due YYYY-MM-DD`.
   - `--done` and `--next` are the same text as the line printed in step 4. Leave `--next` out when there is no next step.
   - Give `--due` only when the next step has a real date (a deadline, a day to check back). Never invent one.
   - The command lists next steps that earlier wraps left open for this directory. If this session finished one, clear it with `python3 ~/.claude/skills/wrap/record.py close <id>`; leave the rest alone.

Don't summarize the whole session, re-explain finished work, or suggest new work.
