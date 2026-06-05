extends Node

const NORMAL_MAX_LEVEL := 30
const VISUAL_TIER_SIZE := 10
const ELITE_MAX := 5
const REQUIRED_ELITE_FOR_DAMAVAND := 1
const DAMAVAND_LEVEL_ID := "level_08_damavand"

const _BASE_COST := 8
const _COST_PER_LEVEL := 4
const _ELITE_BASE_COST := 40
const _ELITE_COST_PER_LEVEL := 15

const _DAMAGE_PER_LEVEL := 0.04
const _RANGE_PER_LEVEL := 0.01
const _ELITE_DAMAGE_BONUS := 0.50
const _ELITE_RANGE_BONUS := 0.20

const EXPECTED_FORGE_BY_LEVEL: Dictionary = {
	"level_00_tutorial": 1,
	"level_01": 1,
	"level_02": 2,
	"level_03": 8,
	"level_04": 12,
	"level_05": 16,
	"level_06": 20,
	"level_07": 25,
	"level_08_damavand": 30,
}

const FORGE_GATE_START_INDEX := 3

func get_tower_data(tower_id: String) -> TowerData:
	return ContentRegistry.get_tower(tower_id) if ContentRegistry else null


func get_material_id_for_tower(tower_id: String) -> String:
	var td := get_tower_data(tower_id)
	return td.forge_material_id if td else ""


func get_material_name(material_id: String) -> String:
	for tid in get_all_forgeable_tower_ids():
		var td := get_tower_data(tid)
		if td and td.forge_material_id == material_id:
			return td.forge_material_name
	return material_id


func get_all_forgeable_tower_ids() -> Array[String]:
	var ids: Array[String] = []
	if ContentRegistry == null or ContentRegistry.bootstrap == null:
		return ids
	for t in ContentRegistry.bootstrap.towers:
		if t.forge_material_id != "":
			ids.append(t.tower_id)
	return ids


func get_unlock_cost(tower_id: String) -> int:
	var td := get_tower_data(tower_id)
	return td.unlock_material_cost if td else 0


func get_locked_unlockable_tower_ids() -> Array[String]:
	var ids: Array[String] = []
	for tower_id in ContentCatalog.get_unlockable_tower_ids():
		if SaveSystem and not SaveSystem.is_tower_in_pool(tower_id):
			ids.append(tower_id)
	return ids


func can_unlock_tower(tower_id: String) -> bool:
	if SaveSystem and SaveSystem.is_tower_in_pool(tower_id):
		return false
	var td := get_tower_data(tower_id)
	if td == null or td.forge_material_id == "" or td.unlock_material_cost <= 0:
		return false
	return SaveSystem.get_material(td.forge_material_id) >= td.unlock_material_cost


func unlock_tower_to_pool(tower_id: String) -> bool:
	if not can_unlock_tower(tower_id):
		return false
	var td := get_tower_data(tower_id)
	if not SaveSystem.spend_material(td.forge_material_id, td.unlock_material_cost):
		return false
	SaveSystem.unlock_tower_to_pool(tower_id)
	return true


func get_forge_state(tower_id: String) -> Dictionary:
	if SaveSystem == null:
		return {"level": 1, "elite_level": 0}
	return SaveSystem.get_tower_forge(tower_id)


func get_level(tower_id: String) -> int:
	return int(get_forge_state(tower_id).get("level", 1))


func get_elite_level(tower_id: String) -> int:
	return int(get_forge_state(tower_id).get("elite_level", 0))


func is_elite(tower_id: String) -> bool:
	return get_elite_level(tower_id) >= ELITE_MAX


func is_normal_maxed(tower_id: String) -> bool:
	return get_level(tower_id) >= NORMAL_MAX_LEVEL


func get_visual_tier(tower_id: String) -> int:
	var lvl := get_level(tower_id)
	if is_elite(tower_id):
		return 4
	return clampi(ceili(float(lvl) / float(VISUAL_TIER_SIZE)), 1, 3)


func cost_for_next_level(tower_id: String) -> int:
	var lvl := get_level(tower_id)
	if lvl >= NORMAL_MAX_LEVEL:
		return 0
	return _BASE_COST + (lvl - 1) * _COST_PER_LEVEL


func cost_for_next_elite(tower_id: String) -> int:
	var elite := get_elite_level(tower_id)
	if elite >= ELITE_MAX or not is_normal_maxed(tower_id):
		return 0
	return _ELITE_BASE_COST + elite * _ELITE_COST_PER_LEVEL


func can_forge(tower_id: String) -> bool:
	if not is_normal_maxed(tower_id):
		var mat := get_material_id_for_tower(tower_id)
		if mat == "":
			return false
		return SaveSystem.get_material(mat) >= cost_for_next_level(tower_id)
	return false


func can_forge_elite(tower_id: String) -> bool:
	if not is_normal_maxed(tower_id) or is_elite(tower_id):
		return false
	var mat := get_material_id_for_tower(tower_id)
	if mat == "":
		return false
	return SaveSystem.get_material(mat) >= cost_for_next_elite(tower_id)


func forge(tower_id: String) -> bool:
	if not can_forge(tower_id):
		return false
	var mat := get_material_id_for_tower(tower_id)
	var cost := cost_for_next_level(tower_id)
	if not SaveSystem.spend_material(mat, cost):
		return false
	var state := get_forge_state(tower_id)
	state["level"] = get_level(tower_id) + 1
	SaveSystem.set_tower_forge(tower_id, state)
	return true


func forge_elite(tower_id: String) -> bool:
	if not can_forge_elite(tower_id):
		return false
	var mat := get_material_id_for_tower(tower_id)
	var cost := cost_for_next_elite(tower_id)
	if not SaveSystem.spend_material(mat, cost):
		return false
	var state := get_forge_state(tower_id)
	state["elite_level"] = get_elite_level(tower_id) + 1
	SaveSystem.set_tower_forge(tower_id, state)
	return true


func get_damage_mult(tower_id: String) -> float:
	var lvl := get_level(tower_id)
	var mult := 1.0 + float(lvl - 1) * _DAMAGE_PER_LEVEL
	if is_elite(tower_id):
		mult += _ELITE_DAMAGE_BONUS
	return mult


func get_range_mult(tower_id: String) -> float:
	var lvl := get_level(tower_id)
	var mult := 1.0 + float(lvl - 1) * _RANGE_PER_LEVEL
	if is_elite(tower_id):
		mult += _ELITE_RANGE_BONUS
	return mult


func get_forge_color(base: Color, tier: int, elite: bool) -> Color:
	var c := base
	match tier:
		2:
			c = c.lerp(Color(0.95, 0.85, 0.5), 0.25)
		3:
			c = c.lerp(Color(0.9, 0.75, 0.35), 0.4)
		4:
			c = c.lerp(Color(0.85, 0.65, 0.95), 0.35)
	if elite:
		c = c.lerp(Color(1.0, 0.92, 0.55), 0.3)
	return c


func get_forge_size(tier: int, elite: bool) -> float:
	var size := 36.0
	match tier:
		2:
			size = 40.0
		3:
			size = 44.0
		4:
			size = 48.0
	if elite:
		size += 4.0
	return size


func count_elite_towers() -> int:
	var count := 0
	for tid in get_all_forgeable_tower_ids():
		if is_elite(tid):
			count += 1
	return count


func can_enter_damavand() -> bool:
	return count_elite_towers() >= REQUIRED_ELITE_FOR_DAMAVAND


func is_damavand_level(level_id: String) -> bool:
	return level_id == DAMAVAND_LEVEL_ID


func expected_forge_level_for(level_id: String) -> int:
	return int(EXPECTED_FORGE_BY_LEVEL.get(level_id, 1))


func expected_damage_mult_for_level(level_id: String) -> float:
	var expected := expected_forge_level_for(level_id)
	return 1.0 + float(expected - 1) * _DAMAGE_PER_LEVEL


func get_average_forge_level() -> float:
	var ids := get_all_forgeable_tower_ids()
	if ids.is_empty():
		return 1.0
	var total := 0.0
	for tid in ids:
		total += float(get_level(tid))
	return total / float(ids.size())


func get_average_forge_level_floor() -> int:
	return int(floor(get_average_forge_level()))


func is_under_forge_recommendation(level_id: String) -> bool:
	if ContentCatalog.khan_index(level_id) < FORGE_GATE_START_INDEX:
		return false
	return get_average_forge_level() < float(expected_forge_level_for(level_id))


func forge_gate_applies_to_level(level_id: String) -> bool:
	return ContentCatalog.khan_index(level_id) >= FORGE_GATE_START_INDEX


func format_forge_recommendation(level_id: String) -> String:
	var expected := expected_forge_level_for(level_id)
	var current := get_average_forge_level_floor()
	return "Recommended forge: Lv %d (you: Lv %d)" % [expected, current]
