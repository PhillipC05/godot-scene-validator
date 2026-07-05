@tool
extends Node
## Demo script for exercising every category the Scene Validator checks:
## broken NodePath (target_path), unset export (target_resource), an
## orphaned "pressed" connection (see test_scene.tscn — no matching method
## here on purpose), and an ownerless node (OrphanChild added below).

@export var target_path: NodePath
@export var target_resource: Resource

func _ready() -> void:
	if Engine.is_editor_hint() and get_node_or_null("OrphanChild") == null:
		var orphan := Node.new()
		orphan.name = "OrphanChild"
		add_child(orphan)
