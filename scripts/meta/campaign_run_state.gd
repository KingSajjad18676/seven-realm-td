class_name CampaignRunState
extends RefCounted

const NODE_SKIRMISH := "node_skirmish"
const NODE_ANVIL := "node_anvil"
const NODE_SHRINE := "node_shrine"
const NODE_LABOUR_BOSS := "node_labour_boss"
const NODE_FINALE := "node_finale"

var seed: int = 0
var nodes: Array[Dictionary] = []
var current_node_id: String = ""
var visited_node_ids: Array[String] = []
var run_tower_ids: Array[String] = []
var run_tower_upgrades: Dictionary = {}
var relic_ids: Array[String] = []
var act_index: int = 0


func generate_run(rng: RandomNumberGenerator = null) -> void:
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.seed = int(Time.get_unix_time_from_system()) % 100000
	seed = int(rng.seed)
	nodes = CampaignRunGenerator.generate(seed)
	current_node_id = _find_start_node_id()
	visited_node_ids.clear()
	run_tower_ids.clear()
	run_tower_upgrades.clear()
	relic_ids.clear()
	act_index = 1


func _find_start_node_id() -> String:
	for n in nodes:
		if str(n.get("type", "")) == NODE_SKIRMISH and int(n.get("act", 1)) == 1:
			return str(n.get("id", ""))
	if not nodes.is_empty():
		return str(nodes[0].get("id", ""))
	return ""


func get_node(node_id: String) -> Dictionary:
	for n in nodes:
		if str(n.get("id", "")) == node_id:
			return n
	return {}


func get_current_node() -> Dictionary:
	return get_node(current_node_id)


func get_reachable_node_ids() -> Array[String]:
	var reachable: Array[String] = []
	var current := get_current_node()
	if current.is_empty():
		return reachable
	if not bool(current.get("cleared", false)):
		reachable.append(current_node_id)
	else:
		_append_open_edges(reachable, current)
	for visited_id in visited_node_ids:
		var visited := get_node(visited_id)
		if visited.is_empty() or not bool(visited.get("cleared", false)):
			continue
		_append_open_edges(reachable, visited)
	return reachable


func _append_open_edges(reachable: Array[String], from_node: Dictionary) -> void:
	var edges: Variant = from_node.get("edges", [])
	if edges is Array:
		for edge_id in edges:
			var nid := str(edge_id)
			var node := get_node(nid)
			if node.is_empty() or bool(node.get("cleared", false)):
				continue
			if nid not in reachable:
				reachable.append(nid)


func mark_node_cleared(node_id: String) -> void:
	for i in nodes.size():
		if str(nodes[i].get("id", "")) == node_id:
			nodes[i]["cleared"] = true
			break
	if node_id not in visited_node_ids:
		visited_node_ids.append(node_id)


func advance_to_node(node_id: String) -> bool:
	if node_id not in get_reachable_node_ids() and node_id != current_node_id:
		return false
	current_node_id = node_id
	var node := get_node(node_id)
	act_index = int(node.get("act", act_index))
	return true


func is_run_complete() -> bool:
	var finale := get_node_by_type(NODE_FINALE)
	if finale.is_empty():
		return false
	return bool(finale.get("cleared", false))


func get_node_by_type(node_type: String) -> Dictionary:
	for n in nodes:
		if str(n.get("type", "")) == node_type:
			return n
	return {}


func set_run_towers(tower_ids: Array[String]) -> void:
	run_tower_ids = tower_ids.duplicate()


func add_run_tower(tower_id: String) -> void:
	if tower_id == "" or tower_id in run_tower_ids:
		return
	run_tower_ids.append(tower_id)


func add_run_tower_upgrade(tower_id: String, amount: int = 1) -> void:
	if tower_id == "":
		return
	run_tower_upgrades[tower_id] = int(run_tower_upgrades.get(tower_id, 0)) + amount


func to_dict() -> Dictionary:
	return {
		"seed": seed,
		"nodes": nodes.duplicate(true),
		"current_node_id": current_node_id,
		"visited_node_ids": visited_node_ids.duplicate(),
		"run_tower_ids": run_tower_ids.duplicate(),
		"run_tower_upgrades": run_tower_upgrades.duplicate(),
		"relic_ids": relic_ids.duplicate(),
		"act_index": act_index,
	}


static func from_dict(data: Dictionary) -> CampaignRunState:
	var run := CampaignRunState.new()
	run.seed = int(data.get("seed", 0))
	run.nodes.clear()
	var saved_nodes: Variant = data.get("nodes", [])
	if saved_nodes is Array:
		for node in saved_nodes:
			if node is Dictionary:
				run.nodes.append(node.duplicate(true))
	run.current_node_id = str(data.get("current_node_id", ""))
	run.visited_node_ids.clear()
	var saved_visited: Variant = data.get("visited_node_ids", [])
	if saved_visited is Array:
		for vid in saved_visited:
			run.visited_node_ids.append(str(vid))
	run.run_tower_ids.clear()
	var saved_towers: Variant = data.get("run_tower_ids", [])
	if saved_towers is Array:
		for tid in saved_towers:
			run.run_tower_ids.append(str(tid))
	run.run_tower_upgrades = data.get("run_tower_upgrades", {}).duplicate()
	run.relic_ids.clear()
	var saved_relics: Variant = data.get("relic_ids", [])
	if saved_relics is Array:
		for relic_id in saved_relics:
			run.relic_ids.append(str(relic_id))
	run.act_index = int(data.get("act_index", 0))
	if run.current_node_id == "" and not run.nodes.is_empty():
		run.current_node_id = run._find_start_node_id()
	return run
