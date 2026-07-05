# Asset Library Submission — Scene Validator

Field values to paste into the web form (or feed into `scripts/submit_asset_library.py`).
Source: https://github.com/godotengine/godot-asset-library/blob/master/API.md,
category IDs confirmed live from `GET https://godotengine.org/asset-library/api/configure`.

## Prerequisites (must be done manually — can't be automated)

- [ ] Push this repo to a **public** GitHub repo (e.g. `github.com/<you>/godot-scene-validator`).
- [ ] Create a git **tag or release** — the Asset Library snapshots a specific commit/tag, not a moving branch.
- [ ] Host an icon image (128×128 PNG recommended) somewhere with a direct URL — e.g.
      `https://raw.githubusercontent.com/<you>/godot-scene-validator/<tag>/addons/scene_validator/icon.png`.
      An `icon.svg` placeholder is in `addons/scene_validator/` — export it to PNG first.
- [ ] Have (or create) a godotengine.org account — this is what `POST /login` authenticates against,
      the same account used for the website/forum, not a separate API-only credential.

## Field values

| Field | Value |
|---|---|
| `title` | Scene Validator |
| `description` | Scans the currently open scene for common mistakes before they become runtime errors: broken NodePath references, unset @export Node/Resource values, orphaned signal connections (script removed or renamed), and ownerless nodes that get silently dropped on save. Results appear in a dockable bottom panel with a jump-to-node button on every row. Optional automatic re-scan on scene save. |
| `category_id` | `5` (Tools) |
| `godot_version` | `4.3` (lowest version you've actually tested against — bump if you test on a different baseline) |
| `version_string` | `1.0.0` |
| `cost` | `MIT` |
| `download_provider` | `GitHub` |
| `download_commit` | `<tag, e.g. v1.0.0>` — fill in after tagging |
| `browse_url` | `https://github.com/<you>/godot-scene-validator` |
| `issues_url` | `https://github.com/<you>/godot-scene-validator/issues` |
| `icon_url` | `<hosted PNG URL>` — fill in after hosting the icon |
| `download_url` | `https://github.com/<you>/godot-scene-validator/archive/refs/tags/<tag>.zip` |

## Category reference (from `/configure`)

| ID | Name |
|---|---|
| 1 | 2D Tools |
| 2 | 3D Tools |
| 3 | Shaders |
| 4 | Materials |
| 5 | Tools |
| 6 | Scripts |
| 7 | Misc |

## Submitting

**Manual:** https://godotengine.org/asset-library/asset/submit — paste the values above.

**Scripted:** see `scripts/submit_asset_library.py`. Fill in the blanks in `scripts/asset_library.json`
first (repo URL, tag, icon URL), then:

```bash
export ASSETLIB_USERNAME=your_username
export ASSETLIB_PASSWORD=your_password
python scripts/submit_asset_library.py            # dry run — prints the payload, sends nothing
python scripts/submit_asset_library.py --live     # actually calls POST /login and POST /asset
```

The submission still goes into moderator review afterward — the script only automates the form-filling
step, not approval.
