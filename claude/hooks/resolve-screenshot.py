#!/usr/bin/env python3
"""UserPromptSubmit hook: resolve bare image filenames to real paths.

Reads the hook payload on stdin. If the prompt mentions an image filename with
no directory part (e.g. "2026-07-14_18-12.png"), look for it in
~/Pictures/Screenshots/, then ~/Downloads/, then the cwd, and inject the first
hit as additional context. Stays silent when nothing resolves.
"""

import json
import re
import sys
from pathlib import Path

EXTS = ("png", "jpg", "jpeg", "gif", "webp", "bmp", "tiff", "avif")
TOKEN = re.compile(
    r"(?:^|[\s\"'`(\[])([^\s/\\\"'`()\[\]]+\.(?:" + "|".join(EXTS) + r"))(?=$|[\s\"'`)\],.:;!?])",
    re.IGNORECASE,
)


def main() -> None:
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return

    prompt = payload.get("prompt") or ""
    cwd = payload.get("cwd") or "."
    names = list(dict.fromkeys(TOKEN.findall(prompt)))
    if not names:
        return

    search_dirs = [
        Path.home() / "Pictures" / "Screenshots",
        Path.home() / "Downloads",
        Path(cwd),
    ]

    lines = []
    for name in names[:5]:
        for d in search_dirs:
            candidate = d / name
            try:
                if candidate.is_file():
                    lines.append(f"- `{name}` resolves to: {candidate}")
                    break
            except OSError:
                continue
        else:
            searched = ", ".join(str(d) for d in search_dirs)
            lines.append(f"- `{name}` was NOT found in any of: {searched}")

    context = (
        "The user's message mentions image filename(s) with no directory part. "
        "Resolved against ~/Pictures/Screenshots/, then ~/Downloads/, then the cwd:\n"
        + "\n".join(lines)
        + "\n\nIf a path resolved, read it with the Read tool before responding — the user "
        "pasted it because they want you to look at it. If it was not found, say so rather "
        "than guessing at another path."
    )

    json.dump(
        {
            "hookSpecificOutput": {
                "hookEventName": "UserPromptSubmit",
                "additionalContext": context,
            },
            "suppressOutput": True,
        },
        sys.stdout,
    )


if __name__ == "__main__":
    main()
