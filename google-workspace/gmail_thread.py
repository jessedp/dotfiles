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
base64-decode → "thread-f:<decimal>"; hex(decimal) is the API thread id. (Verified 2026-10-20 on 3 threads.)
"msg-f:<decimal>" is a message id (resolved to its thread). Threads you started decode to "thread-a:r<signed
decimal>", a random client-side id with no API mapping (verified 2026-11-17): the script then lists best
guesses (threads whose first message you sent, newest activity first) to pick from.
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
    kind, _, num = raw.rpartition(":")
    if num.isdigit():  # thread-f:<dec> (received) or msg-f:<dec> (single message)
        hid = format(int(num), "x")
        if kind.startswith("msg"):
            return gm.users().messages().get(userId="me", id=hid, format="minimal").execute()["threadId"]
        return hid
    # thread-a:r<signed dec> = a thread you started in Gmail web/app. The r-number is a random client-side id:
    # checked 2026-11-17 against 17 (r, API id) pairs, it appears nowhere in the API data, raw MIME or the
    # Message-ID bytes. Only Gmail's web DOM (data-legacy-thread-id) maps it. Best guess: threads whose first
    # message you sent, most recent activity first.
    print(f"Token decodes to {raw!r}: a thread you started; the API can't resolve that id.\n"
          "Best guesses, threads you started, newest activity first (rerun with the id):", file=sys.stderr)
    shown = 0
    for t in gm.users().threads().list(userId="me", q="from:me newer_than:90d", maxResults=40).execute().get("threads", []):
        th = gm.users().threads().get(userId="me", id=t["id"], format="metadata",
                                      metadataHeaders=["Subject", "To", "Date"]).execute()
        first = th["messages"][0]
        if "SENT" not in first.get("labelIds", []):
            continue
        h = {x["name"]: x["value"] for x in first["payload"]["headers"]}
        last = datetime.datetime.fromtimestamp(int(th["messages"][-1]["internalDate"]) / 1000).strftime("%m-%d %H:%M")
        print(t["id"], f"{len(th['messages'])} msgs | last {last} | to {h.get('To', '')[:40]} | {h.get('Subject', '')}")
        shown += 1
        if shown == 12:
            break
    sys.exit(2)


def list_threads(q, n=50):
    for t in gm.users().threads().list(userId="me", q=q, maxResults=n).execute().get("threads", []):
        th = gm.users().threads().get(userId="me", id=t["id"], format="metadata",
                                      metadataHeaders=["Subject", "From", "Date"]).execute()
        h = {x["name"]: x["value"] for x in th["messages"][-1]["payload"]["headers"]}
        print(t["id"], f"{len(th['messages'])} msgs |", h.get("Date", "")[:22], "|", h.get("From", ""), "|", h.get("Subject", ""))


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
    list_threads(a.search)
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
