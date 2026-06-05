class_name RogueliteRunState
extends RefCounted

var seed: int = 0
var nodes: Array[Dictionary] = []
var current_index: int = 0
var relic_ids: Array[String] = []


func generate_run() -> void:
	seed = int(Time.get_unix_time_from_system()) % 100000
	nodes = [
		{"type": "battle", "level_id": "level_01", "label": "Woodland"},
		{"type": "rest", "relic_pick": true, "label": "Sacred Rest"},
		{"type": "battle", "level_id": "level_02", "label": "Desert"},
		{"type": "elite", "level_id": "level_03", "label": "Canyon Elite"},
		{"type": "battle", "level_id": "level_04", "label": "Feast Trial"},
	]
	current_index = 0
	relic_ids.clear()


func get_current_node() -> Dictionary:
	if current_index >= 0 and current_index < nodes.size():
		return nodes[current_index]
	return {}


func advance() -> bool:
	current_index += 1
	return current_index < nodes.size()
