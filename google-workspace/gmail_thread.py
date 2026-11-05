# /// script
# dependencies = ["google-api-python-client", "google-auth"]
# ///
"""Read a Gmail thread (full bodies, attachment list) from a pasted Gmail URL, URL token or API id.

  uv run ~/.config/google-workspace/gmail_thread.py '<gmail url | FMfcgz… token | thread id>'
  uv run ~/.config/google-workspace/gmail_thread.py --search 'subject:V-26-152 newer_than:30d'
  uv run ~/.config/google-workspace/gmail_thread.py --get <msg_id> "<attachment name>" <dest_dir>

Read-only by intent: uses token-ro.json when present, else token.json. Never sends, drafts or labels.

Gmail web URL token → API thread id: the token is a base-40 number over
BCDFGHJKLMNPQRSTVWXZbcdfghjklmnpqrstvwxz; rewrite it in base 64 over the standard b64 alphabet,
base64-decode → "f:<decimal>"; hex(decimal) is the API thread id. (Verified 2026-10-20 on 3 threads.)
"""
import argparse, base64, datetime, html, re, sys
from pathlib import Path
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build

HERE = Path.home() / ".config/google-workspace"  # secrets live here, not in this (public) repo
TOKEN = next(p for p in (HERE / "token-ro.json", HERE / "token.json") if p.exists())
R40 = "BCDFGHJKLMNPQRSTVWXZbcdfghjklmnpqrstvwxz"
B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
JUNK_ATT = re.compile(r"(image\d*|Outlook-.*|~WRD\d+)\.(png|jpe?g|gif)$|\.ics$", re.I)


def thread_id(arg):
    tok = arg.rstrip("/").split("/")[-1].split("?")[0]
    if re.fullmatch(r"[0-9a-f]{16}", tok):
        return tok
    n = 0
    for ch in tok:
        n = n * 40 + R40.index(ch)
    s = ""
    while n:
        n, r = divmod(n, 64)
        s = B64[r] + s
    raw = base64.b64decode(s + "=" * (-len(s) % 4)).decode()
    return format(int(raw.split(":")[-1]), "x")


def body(p):
    if p.get("mimeType") == "text/plain" and p["body"].get("data"):
        return base64.urlsafe_b64decode(p["body"]["data"]).decode("utf-8", "replace")
    for q in p.get("parts") or []:
        b = body(q)
        if b:
            return b
    if p.get("mimeType") == "text/html" and p["body"].get("data"):
        t = base64.urlsafe_b64decode(p["body"]["data"]).decode("utf-8", "replace")
        t = re.sub(r"<style.*?</style>", "", t, flags=re.S)
        return html.unescape(re.sub(r"<[^>]+>", " ", re.sub(r"<br\s*/?>|</p>|</div>", "\n", t)))
    return ""


def atts(p, acc):
    if p.get("filename") and not JUNK_ATT.search(p["filename"]):
        acc.append(p["filename"])
    for q in p.get("parts") or []:
        atts(q, acc)
    return acc


def find_att(p, name):
    if p.get("filename") == name:
        return p["body"]["attachmentId"]
    for q in p.get("parts") or []:
        a = find_att(q, name)
        if a:
            return a


gm = build("gmail", "v1", credentials=Credentials.from_authorized_user_file(str(TOKEN)))
ap = argparse.ArgumentParser()
ap.add_argument("thread", nargs="?")
ap.add_argument("--search")
ap.add_argument("--get", nargs=3, metavar=("MSG_ID", "NAME", "DEST_DIR"))
a = ap.parse_args()

if a.get:
    mid, name, dest = a.get
    m = gm.users().messages().get(userId="me", id=mid, format="full").execute()
    aid = find_att(m["payload"], name) or sys.exit(f"no attachment {name!r} on {mid}")
    data = gm.users().messages().attachments().get(userId="me", messageId=mid, id=aid).execute()["data"]
    p = Path(dest) / name
    p.write_bytes(base64.urlsafe_b64decode(data))
    print("saved", p)
elif a.search:
    for t in gm.users().threads().list(userId="me", q=a.search, maxResults=50).execute().get("threads", []):
        th = gm.users().threads().get(userId="me", id=t["id"], format="metadata",
                                      metadataHeaders=["Subject", "From", "Date"]).execute()
        h = {x["name"]: x["value"] for x in th["messages"][-1]["payload"]["headers"]}
        print(t["id"], f"{len(th['messages'])} msgs |", h.get("Date", "")[:22], "|", h.get("From", ""), "|", h.get("Subject", ""))
elif a.thread:
    th = gm.users().threads().get(userId="me", id=thread_id(a.thread), format="full").execute()
    for m in th["messages"]:
        h = {x["name"]: x["value"] for x in m["payload"]["headers"]}
        dt = datetime.datetime.fromtimestamp(int(m["internalDate"]) / 1000).strftime("%Y-%m-%d %H:%M")
        at = atts(m["payload"], [])
        print(f"\n{'=' * 70}\n{dt} | {h.get('From', '')}\nTo: {h.get('To', '')}  Cc: {h.get('Cc', '')}\n"
              f"Subject: {h.get('Subject', '')} | msg {m['id']}" + (f"\n[att: {', '.join(at)}]" if at else ""))
        print((body(m["payload"]) or "").replace("\r", "").replace("\xa0", " ").strip())
else:
    ap.print_help()
