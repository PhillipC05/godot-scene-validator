# Scene Validator

A Godot 4 editor plugin that scans the currently open scene for common mistakes
before they turn into runtime errors:

- **Broken `NodePath` references** — exported or stored `NodePath` properties
  that no longer resolve to a node.
- **Unset `@export` values** — exported `Node`/`Resource`/`PackedScene`
  properties left `null`, the classic "Nil doesn't have method" crash.
- **Orphaned signal connections** — connections in the scene file that target
  a method on a script that was removed, renamed, or detached.
- **Ownerless nodes** — nodes with no `owner` set, which are silently dropped
  the next time the scene is saved.

Results show up in a dockable **Scene Validator** panel at the bottom of the
editor, with a button on each row to jump straight to the offending node in
the Scene dock.

## Installation

1. Copy `addons/scene_validator/` into your project's `addons/` folder.
2. In Godot: **Project → Project Settings → Plugins**, enable **Scene Validator**.
3. Open the **Scene Validator** tab in the bottom panel.

## Usage

- Click **Validate Scene** to scan the currently open scene on demand.
- Check **Run on Scene Save** to have it re-scan automatically every time you
  save a scene.
- Click the button next to any result row to select that node in the editor.

## How it works

All scanning logic lives in `scene_validator.gd`, a plain `RefCounted` script
with no editor dependencies — it walks the live scene tree with
`get_property_list()`, `get_incoming_connections()`, and `owner` checks. The
`EditorPlugin` (`plugin.gd`) only wires that logic to the dock UI
(`validator_panel.gd` / `.tscn`) and to the `resource_saved` signal for the
optional on-save trigger.

## License

MIT — see `LICENSE`.
