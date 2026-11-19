#!/usr/bin/env python3
"""Log of /wrap handles: one JSON line per wrapped session, so a scanner can list
open next steps without reading transcripts.

Files live in ~/.claude-memory/wraps/<writing host>.jsonl. One file per host means
two machines never edit the same file, and ~/.claude-memory/bin/sync.sh carries them
everywhere. The log is append-only: a next step is cleared by a later line, never by
editing an old one.

    record.py add --session ID --cwd DIR --topic "..." --done "..." [--next "..."] [--due YYYY-MM-DD]
    record.py open [--cwd DIR] [--json]     # next steps still open, soonest due first
    record.py close ID [ID ...]             # clear next steps (session ids, 8+ chars is enough)

A session's newest line wins. Its next step is open until a later line closes it.
"""

import argparse
import datetime
import json
import os
import socket
import sys
from pathlib import Path

DIR = Path(os.environ.get("WRAP_LOG_DIR") or Path.home() / ".claude-memory" / "wraps")


def now() -> str:
    return datetime.datetime.now().astimezone().isoformat(timespec="seconds")


def when(rec: dict) -> datetime.datetime:
    return datetime.datetime.fromisoformat(rec["ts"])


def load() -> list[dict]:
    recs = []
    for f in sorted(DIR.glob("*.jsonl")):
        for n, line in enumerate(f.read_text().splitlines(), 1):
            if not line.strip():
                continue
            try:
                rec = json.loads(line)
                when(rec)
            except (ValueError, KeyError, TypeError):
                print(f"skipped unreadable line {f.name}:{n}", file=sys.stderr)
                continue
            recs.append(rec)
    recs.sort(key=when)
    return recs


def append(rec: dict) -> Path:
    DIR.mkdir(parents=True, exist_ok=True)
    path = DIR / f"{socket.gethostname()}.jsonl"
    line = json.dumps(rec, ensure_ascii=False) + "\n"
    fd = os.open(path, os.O_WRONLY | os.O_APPEND | os.O_CREAT, 0o644)
    try:
        os.write(fd, line.encode())
    finally:
        os.close(fd)
    return path


def open_items(recs: list[dict]) -> list[dict]:
    latest: dict[str, dict] = {}
    for r in recs:
        if r.get("session"):
            latest[r["session"]] = r
    items = []
    for sid, r in latest.items():
        if not r.get("next"):
            continue
        closed = any(
            when(c) > when(r) and any(sid.startswith(p) for p in c.get("closes") or [])
            for c in recs
        )
        if not closed:
            items.append(r)
    items.sort(key=lambda r: (r.get("due") or "9999", r["ts"]))
    return items


def show(items: list[dict]) -> None:
    for r in items:
        due = r.get("due") or "no date   "
        print(f"{due}  {r['session'][:8]}  {r.get('host', '?')}:{r.get('cwd', '?')}")
        print(f"            {r.get('topic') or '(no topic)'}: {r['next']}")


def valid_date(s: str) -> str:
    return datetime.date.fromisoformat(s).isoformat()


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="cmd", required=True)

    a = sub.add_parser("add", help="record a wrapped session")
    a.add_argument("--session", required=True)
    a.add_argument("--cwd", required=True, help="launch directory (where `claude --resume` works)")
    a.add_argument("--topic", required=True, help="2-5 words naming the piece of work")
    a.add_argument("--done", required=True)
    a.add_argument("--next", default=None, help="the single next step, if any")
    a.add_argument("--due", type=valid_date, default=None, help="only when the next step has a real date")
    a.add_argument("--host", default=socket.gethostname(), help="host the session lives on (default: this one)")
    a.add_argument("--ts", default=None, help="when the session ended, ISO 8601 (default: now)")
    a.add_argument("--source", default="wrap", help="wrap (default) or catchup")

    o = sub.add_parser("open", help="list open next steps")
    o.add_argument("--cwd", default=None)
    o.add_argument("--json", action="store_true")

    c = sub.add_parser("close", help="clear next steps by session id")
    c.add_argument("ids", nargs="+")

    args = p.parse_args()

    if args.cmd == "add":
        if args.due and not args.next:
            p.error("--due needs --next")
        ts = args.ts or now()
        if datetime.datetime.fromisoformat(ts).tzinfo is None:
            p.error("--ts needs a UTC offset, e.g. 2026-11-18T14:30:00-05:00")
        cwd = str(Path(args.cwd).expanduser())
        rec = {
            "ts": ts,
            "host": args.host,
            "cwd": cwd,
            "session": args.session,
            "topic": args.topic,
            "done": args.done,
            "next": args.next,
            "due": args.due,
            "source": args.source,
        }
        path = append(rec)
        print(f"recorded in {path}")
        others = [r for r in open_items(load()) if r.get("cwd") == cwd and r["session"] != args.session]
        if others:
            print(f"\nOther open next steps for {cwd} (close any this session finished):")
            show(others)
        return 0

    if args.cmd == "open":
        items = open_items(load())
        if args.cwd:
            cwd = str(Path(args.cwd).expanduser())
            items = [r for r in items if r.get("cwd") == cwd]
        if args.json:
            json.dump(items, sys.stdout, ensure_ascii=False, indent=1)
            print()
        elif items:
            show(items)
        else:
            print("no open next steps")
        return 0

    if args.cmd == "close":
        short = [i for i in args.ids if len(i) < 8]
        if short:
            p.error(f"session ids need at least 8 characters: {' '.join(short)}")
        known = {r["session"] for r in open_items(load())}
        missing = [i for i in args.ids if not any(s.startswith(i) for s in known)]
        if missing:
            print(f"no open next step matches: {' '.join(missing)}", file=sys.stderr)
            return 1
        append({"ts": now(), "host": socket.gethostname(), "closes": args.ids})
        print(f"closed {len(args.ids)}")
        return 0

    return 2


if __name__ == "__main__":
    sys.exit(main())
