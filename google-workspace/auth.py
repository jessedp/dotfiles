# /// script
# dependencies = ["google-auth-oauthlib"]
# ///
# uv run auth.py        → token.json     (read/write scopes)
# uv run auth.py --ro   → token-ro.json  (read-only scopes; what agents and read tools should use)
import sys
from pathlib import Path
from google_auth_oauthlib.flow import InstalledAppFlow

HERE = Path.home() / ".config/google-workspace"  # secrets live here, not in this (public) repo
G = "https://www.googleapis.com/auth/"
RW = ["drive", "documents", "presentations", "spreadsheets", "gmail.modify", "calendar", "tasks"]
RO = ["drive.readonly", "documents.readonly", "presentations.readonly", "spreadsheets.readonly",
      "gmail.readonly", "calendar.readonly", "tasks.readonly"]
ro = "--ro" in sys.argv
flow = InstalledAppFlow.from_client_secrets_file(str(HERE / "client_secret.json"), [G + s for s in (RO if ro else RW)])
creds = flow.run_local_server(port=0, access_type="offline", prompt="consent")
tok = HERE / ("token-ro.json" if ro else "token.json")
tok.write_text(creds.to_json()); tok.chmod(0o600)
print("saved", tok)
