class_name RogueliteRunState
extends RefCounted

var seed: int = 0
var nodes: Array[Dictionary] = []
var current_index: int = 0
var relic_ids: Array[String] = []


func generate_run() -> void:
	seed = int(Time.get_unix_time_from_system()) % 100000
	nodes.clear()
	nodes.append({"type": "battle", "level_id": "level_01", "label": "Woodland"})
	nodes.append({"type": "rest", "relic_pick": true, "label": "Sacred Rest"})
	nodes.append({"type": "battle", "level_id": "level_02", "label": "Desert"})
	nodes.append({"type": "elite", "level_id": "level_03", "label": "Canyon Elite"})
	nodes.append({"type": "battle", "level_id": "level_04", "label": "Feast Trial"})
	current_index = 0
	relic_ids.clear()


func get_current_node() -> Dictionary:
	if current_index >= 0 and current_index < nodes.size():
		return nodes[current_index]
	return {}


func advance() -> bool:
	current_index += 1
	return current_index < nodes.size()


func to_dict() -> Dictionary:
	return {
		"seed": seed,
		"nodes": nodes.duplicate(true),
		"current_index": current_index,
		"relic_ids": relic_ids.duplicate(),
	}


static func from_dict(data: Dictionary) -> RogueliteRunState:
	var run := RogueliteRunState.new()
	run.seed = int(data.get("seed", 0))
	var saved_nodes: Variant = data.get("nodes", [])
	run.nodes.clear()
	if saved_nodes is Array:
		for node in saved_nodes:
			if node is Dictionary:
				run.nodes.append(node.duplicate(true))
	run.current_index = int(data.get("current_index", 0))
	run.relic_ids.clear()
	var saved_relics: Variant = data.get("relic_ids", [])
	if saved_relics is Array:
		for relic_id in saved_relics:
			run.relic_ids.append(str(relic_id))
	return run
