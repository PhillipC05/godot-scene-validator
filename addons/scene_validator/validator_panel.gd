@tool
extends VBoxContainer

const JUMP_BUTTON_ID := 0

var editor_plugin: EditorPlugin
var _issue_by_item: Dictionary = {}

@onready var _validate_button: Button = %ValidateButton
@onready var _run_on_save_check: CheckBox = %RunOnSaveCheck
@onready var _status_label: Label = %StatusLabel
@onready var _results_tree: Tree = %ResultsTree

func _ready() -> void:
	_validate_button.pressed.connect(_on_validate_pressed)
	_run_on_save_check.toggled.connect(_on_run_on_save_toggled)
	_results_tree.button_clicked.connect(_on_tree_button_clicked)
	_results_tree.hide_root = true
	_results_tree.columns = 3
	_results_tree.set_column_title(0, "Category")
	_results_tree.set_column_title(1, "Node")
	_results_tree.set_column_title(2, "Message")
	_results_tree.column_titles_visible = true

func _on_validate_pressed() -> void:
	if editor_plugin != null:
		editor_plugin.run_validation()

func _on_run_on_save_toggled(pressed: bool) -> void:
	if editor_plugin != null:
		editor_plugin.run_on_save = pressed

func show_no_scene() -> void:
	_status_label.text = "No scene is currently open."
	_clear_tree()

func show_issues(issues: Array[Dictionary]) -> void:
	_clear_tree()
	if issues.is_empty():
		_status_label.text = "No issues found."
		return
	_status_label.text = "%d issue(s) found." % issues.size()
	var root := _results_tree.create_item()
	for issue in issues:
		var item := _results_tree.create_item(root)
		item.set_text(0, issue["category"])
		item.set_text(1, str(issue["node_path"]))
		item.set_text(2, issue["message"])
		item.add_button(1, get_theme_icon("Play", "EditorIcons"), JUMP_BUTTON_ID, false, "Select node")
		_issue_by_item[item] = issue["node"]

func _clear_tree() -> void:
	_results_tree.clear()
	_issue_by_item.clear()

func _on_tree_button_clicked(item: TreeItem, _column: int, id: int, _mouse_button_index: int) -> void:
	if id != JUMP_BUTTON_ID:
		return
	var node: Node = _issue_by_item.get(item)
	if node != null and is_instance_valid(node) and editor_plugin != null:
		editor_plugin.select_node(node)
