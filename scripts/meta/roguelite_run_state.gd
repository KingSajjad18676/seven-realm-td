class_name RogueliteRunState
extends RefCounted

var seed: int = 0
var nodes: Array[Dictionary] = []
var current_index: int = 0
var tower_relic_slots: Dictionary = {}
var active_relic_ids: Array[String] = []


func generate_run() -> void:
	seed = int(Time.get_unix_time_from_system()) % 100000
	nodes.clear()
	nodes.append({"type": "battle", "level_id": "level_01", "label": "Woodland"})
	nodes.append({"type": "rest", "relic_pick": true, "label": "Sacred Rest"})
	nodes.append({"type": "battle", "level_id": "level_02", "label": "Desert"})
	nodes.append({"type": "elite", "level_id": "level_03", "label": "Canyon Elite"})
	nodes.append({"type": "battle", "level_id": "level_04", "label": "Feast Trial"})
	current_index = 0
	tower_relic_slots.clear()
	active_relic_ids.clear()


func get_current_node() -> Dictionary:
	if current_index >= 0 and current_index < nodes.size():
		return nodes[current_index]
	return {}


func advance() -> bool:
	current_index += 1
	return current_index < nodes.size()


func slot_relic(relic_id: String, tower_id: String) -> void:
	if relic_id == "" or tower_id == "":
		return
	tower_relic_slots[tower_id] = relic_id


func get_slotted_relic_id(tower_id: String) -> String:
	return str(tower_relic_slots.get(tower_id, ""))


func to_dict() -> Dictionary:
	return {
		"seed": seed,
		"nodes": nodes.duplicate(true),
		"current_index": current_index,
		"tower_relic_slots": tower_relic_slots.duplicate(),
		"active_relic_ids": active_relic_ids.duplicate(),
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
	run.tower_relic_slots = data.get("tower_relic_slots", {}).duplicate()
	run.active_relic_ids.clear()
	var saved_global_relics: Variant = data.get("active_relic_ids", [])
	if saved_global_relics is Array:
		for relic_id in saved_global_relics:
			run.active_relic_ids.append(str(relic_id))
	var saved_relics: Variant = data.get("relic_ids", [])
	if saved_relics is Array and run.tower_relic_slots.is_empty() and run.active_relic_ids.is_empty():
		var migrated := RelicSlotHelper.migrate_relic_ids(saved_relics)
		run.tower_relic_slots = migrated.get("tower_relic_slots", {}).duplicate()
		for relic_id in migrated.get("active_relic_ids", []):
			run.active_relic_ids.append(str(relic_id))
	return run
