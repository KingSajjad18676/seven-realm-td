class_name ObjectPool
extends RefCounted

var _scene: PackedScene
var _parent: Node
var _available: Array[Node] = []
var _in_use: Array[Node] = []


func _init(scene: PackedScene, parent: Node, prewarm: int = 4) -> void:
	_scene = scene
	_parent = parent
	for _i in prewarm:
		_available.append(_create_instance())


func acquire() -> Node:
	var node: Node = null
	if _available.size() > 0:
		node = _available.pop_back()
	else:
		node = _create_instance()
	_in_use.append(node)
	node.visible = true
	node.process_mode = Node.PROCESS_MODE_INHERIT
	return node


func in_use_count() -> int:
	return _in_use.size()


func release(node: Node) -> void:
	if node == null:
		return
	var idx := _in_use.find(node)
	if idx >= 0:
		_in_use.remove_at(idx)
	node.visible = false
	node.process_mode = Node.PROCESS_MODE_DISABLED
	if node.get_parent() != _parent:
		_parent.add_child(node)
	_available.append(node)


func _create_instance() -> Node:
	var inst := _scene.instantiate()
	inst.visible = false
	inst.process_mode = Node.PROCESS_MODE_DISABLED
	_parent.add_child(inst)
	return inst
