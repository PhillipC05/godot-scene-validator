@tool
extends RefCounted

## Pure scanning logic for the Scene Validator plugin.
## Kept free of any editor/UI calls so it can be unit-tested headlessly.

const CATEGORY_NODE_PATH := "Broken NodePath"
const CATEGORY_EXPORT_NULL := "Unset Export"
const CATEGORY_MISSING_SCRIPT := "Orphaned Connection"
const CATEGORY_NO_OWNER := "No Owner"

static func scan(root: Node) -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	if root == null:
		return issues
	_scan_node(root, root, issues)
	return issues

static func _scan_node(node: Node, root: Node, issues: Array[Dictionary]) -> void:
	_check_node_paths(node, issues)
	_check_export_nulls(node, issues)
	_check_orphaned_connections(node, issues)
	_check_owner(node, root, issues)
	for child in node.get_children():
		_scan_node(child, root, issues)

static func _add(issues: Array[Dictionary], node: Node, category: String, message: String) -> void:
	issues.append({
		"node": node,
		"node_path": node.get_path(),
		"category": category,
		"message": message,
	})

# Broken NodePath references: any exported/stored NodePath property that
# resolves to nothing relative to the node that owns it.
static func _check_node_paths(node: Node, issues: Array[Dictionary]) -> void:
	for prop in node.get_property_list():
		if prop.type != TYPE_NODE_PATH:
			continue
		if not (prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE or prop.usage & PROPERTY_USAGE_STORAGE):
			continue
		var path: NodePath = node.get(prop.name)
		if path.is_empty():
			continue
		if node.get_node_or_null(path) == null:
			_add(issues, node, CATEGORY_NODE_PATH,
				"Property '%s' points to a missing node: %s" % [prop.name, path])

# @export vars left null: only flags Object-typed exports (Node, Resource,
# PackedScene, etc.) since those are the ones that crash on first use.
static func _check_export_nulls(node: Node, issues: Array[Dictionary]) -> void:
	var script: Script = node.get_script()
	if script == null:
		return
	for prop in script.get_script_property_list():
		if not (prop.usage & PROPERTY_USAGE_EDITOR):
			continue
		if prop.type != TYPE_OBJECT:
			continue
		var value = node.get(prop.name)
		if value == null:
			_add(issues, node, CATEGORY_EXPORT_NULL,
				"Exported property '%s' is unset (null)" % prop.name)

# Missing script attachments surface as connections whose target callable
# can no longer be found because the node's script was removed or renamed.
static func _check_orphaned_connections(node: Node, issues: Array[Dictionary]) -> void:
	for conn in node.get_incoming_connections():
		var callable: Callable = conn.get("callable")
		if callable == null or callable.get_object() != node:
			continue
		if not node.has_method(callable.get_method()):
			var reason := "node has no script" if node.get_script() == null else "method no longer exists"
			_add(issues, node, CATEGORY_MISSING_SCRIPT,
				"Signal connection targets '%s' but %s" % [callable.get_method(), reason])

# Nodes with no owner are silently dropped when the scene is saved — a
# common cause of "it works until I reopen the scene" bugs.
static func _check_owner(node: Node, root: Node, issues: Array[Dictionary]) -> void:
	if node == root:
		return
	if node.owner == null:
		_add(issues, node, CATEGORY_NO_OWNER,
			"Node has no owner and will not be saved with the scene")
