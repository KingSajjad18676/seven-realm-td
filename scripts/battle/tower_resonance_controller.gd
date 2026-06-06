class_name TowerResonanceController
extends Node

const RECIPES: Dictionary = {
	"fire_string": ["tower_sacred_fire", "tower_archer"],
	"quake_bind": ["tower_heavy", "tower_control"],
}
const ADJACENCY_DIST := 64.0

const LINK_COLORS: Dictionary = {
	"fire_string": Color(1.0, 0.55, 0.2, 0.75),
	"quake_bind": Color(0.45, 0.55, 0.85, 0.75),
}

var context: BattleContext = null
var _vfx_root: Node2D = null
var _link_lines: Dictionary = {}


func initialize(ctx: BattleContext, vfx_root: Node2D = null) -> void:
	context = ctx
	_vfx_root = vfx_root


func on_tower_placed(_tower: TowerController) -> void:
	scan_all()


func on_tower_removed(_tower: TowerController) -> void:
	scan_all()


func scan_all() -> void:
	if context == null or context.tower_manager == null:
		return
	_clear_links()
	var towers := context.tower_manager.towers
	var paired: Dictionary = {}
	for i in range(towers.size()):
		var a: TowerController = towers[i]
		if not is_instance_valid(a) or a.data == null:
			continue
		for j in range(i + 1, towers.size()):
			var b: TowerController = towers[j]
			if not is_instance_valid(b) or b.data == null:
				continue
			if a.global_position.distance_to(b.global_position) > ADJACENCY_DIST:
				continue
			var combo_id := _match_recipe(a.data.tower_id, b.data.tower_id)
			if combo_id == "":
				continue
			var pair_key := _pair_key(a, b)
			if paired.has(pair_key):
				continue
			paired[pair_key] = true
			_apply_link(a, b, combo_id)
			_apply_link(b, a, combo_id)
			_draw_link(a, b, combo_id)
			CombatEvents.tower_resonance_linked.emit(combo_id)


func _match_recipe(id_a: String, id_b: String) -> String:
	for combo_id in RECIPES.keys():
		var ids: Array = RECIPES[combo_id]
		if ids.size() < 2:
			continue
		if (id_a == str(ids[0]) and id_b == str(ids[1])) or (id_a == str(ids[1]) and id_b == str(ids[0])):
			return combo_id
	return ""


func _apply_link(tower: TowerController, partner: TowerController, combo_id: String) -> void:
	if combo_id not in tower.resonance_links:
		tower.resonance_links.append(combo_id)
	if partner not in tower.resonance_partners:
		tower.resonance_partners.append(partner)


func _pair_key(a: TowerController, b: TowerController) -> String:
	return "%s|%s" % [a.placement_id, b.placement_id]


func _draw_link(a: TowerController, b: TowerController, combo_id: String) -> void:
	if _vfx_root == null:
		return
	var line := Line2D.new()
	line.width = 3.0
	line.default_color = LINK_COLORS.get(combo_id, Color.WHITE)
	line.points = [a.global_position, b.global_position]
	line.z_index = 1
	_vfx_root.add_child(line)
	_link_lines[_pair_key(a, b)] = line


func _clear_links() -> void:
	if context and context.tower_manager:
		for tower in context.tower_manager.towers:
			if is_instance_valid(tower):
				tower.resonance_links.clear()
				tower.resonance_partners.clear()
	for line in _link_lines.values():
		if is_instance_valid(line):
			(line as Node).queue_free()
	_link_lines.clear()


func _process(_delta: float) -> void:
	if _link_lines.is_empty():
		return
	for key in _link_lines.keys():
		var line: Line2D = _link_lines[key]
		if not is_instance_valid(line):
			continue
		var parts: PackedStringArray = key.split("|")
		if parts.size() != 2:
			continue
		var a := _tower_by_placement_id(parts[0])
		var b := _tower_by_placement_id(parts[1])
		if a == null or b == null:
			continue
		line.points = [a.global_position, b.global_position]


func _tower_by_placement_id(placement_id: String) -> TowerController:
	if context == null or context.tower_manager == null:
		return null
	for tower in context.tower_manager.towers:
		if is_instance_valid(tower) and tower.placement_id == placement_id:
			return tower
	return null
