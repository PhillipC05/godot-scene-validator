#!/usr/bin/env python3
"""Submit (or preview submitting) this addon to the Godot Asset Library.

Uses the documented REST API (godotengine/godot-asset-library API.md) instead
of the web form at https://godotengine.org/asset-library/asset/submit.

Credentials come from the ASSETLIB_USERNAME / ASSETLIB_PASSWORD environment
variables -- never hardcode them, never pass them as CLI args (they'd land in
shell history).

By default this is a dry run: it validates the config and prints the exact
payload that would be sent, but makes no network calls. Pass --live to
actually hit POST /login and POST /asset. The resulting submission still
goes into godotengine.org's normal moderator review queue -- this script only
automates the form-filling step.
"""

import argparse
import json
import os
import sys
import urllib.error
import urllib.request
from pathlib import Path

API_BASE = "https://godotengine.org/asset-library/api"
CONFIG_PATH = Path(__file__).parent / "asset_library.json"
REQUIRED_FIELDS = [
    "title", "description", "category_id", "godot_version", "version_string",
    "cost", "download_provider", "download_commit", "browse_url",
    "issues_url", "icon_url", "download_url",
]


def load_config() -> dict:
    with CONFIG_PATH.open("r", encoding="utf-8") as f:
        config = json.load(f)
    placeholders = [
        key for key, value in config.items()
        if isinstance(value, str) and "REPLACE_WITH" in value
    ]
    if placeholders:
        sys.exit(
            "asset_library.json still has placeholder values for: "
            f"{', '.join(placeholders)}\n"
            "Fill those in (repo URL, tag, hosted icon URL) before submitting."
        )
    missing = [key for key in REQUIRED_FIELDS if not config.get(key)]
    if missing:
        sys.exit(f"asset_library.json is missing required fields: {', '.join(missing)}")
    return config


def post_json(path: str, payload: dict) -> dict:
    url = f"{API_BASE}{path}"
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(url, data=data, headers={"Content-Type": "application/json"}, method="POST")
    try:
        with urllib.request.urlopen(req) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")
        sys.exit(f"{path} failed: HTTP {e.code}\n{body}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--live", action="store_true", help="Actually submit, instead of just printing the payload.")
    args = parser.parse_args()

    config = load_config()

    if not args.live:
        print("DRY RUN -- no network calls made. Payload that would be sent to POST /asset:\n")
        print(json.dumps(config, indent=2))
        print("\nRe-run with --live to actually submit (requires ASSETLIB_USERNAME / ASSETLIB_PASSWORD).")
        return

    username = os.environ.get("ASSETLIB_USERNAME")
    password = os.environ.get("ASSETLIB_PASSWORD")
    if not username or not password:
        sys.exit("Set ASSETLIB_USERNAME and ASSETLIB_PASSWORD environment variables first.")

    print(f"Logging in to {API_BASE} as {username} ...")
    login_resp = post_json("/login", {"username": username, "password": password})
    token = login_resp.get("token")
    if not token:
        sys.exit(f"Login succeeded but no token in response: {login_resp}")

    payload = dict(config)
    payload["token"] = token

    print("Submitting asset ...")
    asset_resp = post_json("/asset", payload)
    print("Response:")
    print(json.dumps(asset_resp, indent=2))
    print("\nSubmitted. This now sits in godotengine.org's moderator review queue.")


if __name__ == "__main__":
    main()
