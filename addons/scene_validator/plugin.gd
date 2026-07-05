@tool
extends EditorPlugin

const SceneValidator = preload("res://addons/scene_validator/scene_validator.gd")
const ValidatorPanelScene = preload("res://addons/scene_validator/validator_panel.tscn")

var run_on_save := false
var _panel: Control

func _enter_tree() -> void:
	_panel = ValidatorPanelScene.instantiate()
	_panel.editor_plugin = self
	add_control_to_bottom_panel(_panel, "Scene Validator")
	resource_saved.connect(_on_resource_saved)

func _exit_tree() -> void:
	resource_saved.disconnect(_on_resource_saved)
	remove_control_from_bottom_panel(_panel)
	_panel.queue_free()

func run_validation() -> void:
	var edited_root := get_editor_interface().get_edited_scene_root()
	if edited_root == null:
		_panel.show_no_scene()
		return
	var issues: Array[Dictionary] = SceneValidator.scan(edited_root)
	_panel.show_issues(issues)

func select_node(node: Node) -> void:
	get_editor_interface().get_selection().clear()
	get_editor_interface().get_selection().add_node(node)
	get_editor_interface().edit_node(node)

func _on_resource_saved(resource: Resource) -> void:
	if not run_on_save or not (resource is PackedScene):
		return
	if get_editor_interface().get_edited_scene_root() != null:
		run_validation()
