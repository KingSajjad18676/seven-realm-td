class_name ContentValidator
extends RefCounted

const MIN_LEVELS := 9
const MIN_ENEMIES := 20
const MIN_FATE_CARDS := 8
const MIN_TOWERS := 6
const MIN_HEROES := 2
const WAVES_PER_LEVEL := 5


static func validate(catalog: BootstrapContent) -> Array[String]:
	var errors: Array[String] = []
	if catalog == null:
		errors.append("catalog is null")
		return errors

	errors.append_array(_check_minimum_counts(catalog))
	errors.append_array(_check_unique_ids(catalog))
	errors.append_array(_check_level_waves(catalog))
	errors.append_array(_check_spot_levels(catalog))
	errors.append_array(_check_boss_factory())
	return errors


static func _check_minimum_counts(catalog: BootstrapContent) -> Array[String]:
	var errors: Array[String] = []
	if catalog.levels.size() < MIN_LEVELS:
		errors.append("levels count %d < %d" % [catalog.levels.size(), MIN_LEVELS])
	if catalog.enemies.size() < MIN_ENEMIES:
		errors.append("enemies count %d < %d" % [catalog.enemies.size(), MIN_ENEMIES])
	if catalog.fate_cards.size() < MIN_FATE_CARDS:
		errors.append("fate_cards count %d < %d" % [catalog.fate_cards.size(), MIN_FATE_CARDS])
	if catalog.towers.size() < MIN_TOWERS:
		errors.append("towers count %d < %d" % [catalog.towers.size(), MIN_TOWERS])
	if catalog.heroes.size() < MIN_HEROES:
		errors.append("heroes count %d < %d" % [catalog.heroes.size(), MIN_HEROES])
	return errors


static func _check_unique_ids(catalog: BootstrapContent) -> Array[String]:
	var errors: Array[String] = []
	errors.append_array(_unique_field(catalog.towers, "tower_id", "tower"))
	errors.append_array(_unique_field(catalog.enemies, "enemy_id", "enemy"))
	errors.append_array(_unique_field(catalog.heroes, "hero_id", "hero"))
	errors.append_array(_unique_field(catalog.levels, "level_id", "level"))
	errors.append_array(_unique_field(catalog.fate_cards, "card_id", "fate_card"))
	return errors


static func _unique_field(items: Array, field: String, label: String) -> Array[String]:
	var errors: Array[String] = []
	var seen: Dictionary = {}
	for item in items:
		if item == null:
			continue
		var id_val := str(item.get(field))
		if id_val == "":
			errors.append("%s missing %s" % [label, field])
			continue
		if seen.has(id_val):
			errors.append("duplicate %s id: %s" % [label, id_val])
		seen[id_val] = true
	return errors


static func _check_level_waves(catalog: BootstrapContent) -> Array[String]:
	var errors: Array[String] = []
	var enemy_ids := {}
	for e in catalog.enemies:
		if e is EnemyData:
			enemy_ids[e.enemy_id] = true
	for level in catalog.levels:
		if not (level is LevelData):
			continue
		if level.waves.size() != WAVES_PER_LEVEL:
			errors.append("level %s has %d waves, expected %d" % [
				level.level_id, level.waves.size(), WAVES_PER_LEVEL
			])
		for wave in level.waves:
			for group in wave.spawn_groups:
				var eid := str(group.get("enemy_id", ""))
				if not enemy_ids.has(eid):
					errors.append("level %s references unknown enemy_id: %s" % [level.level_id, eid])
	return errors


static func _check_spot_levels(catalog: BootstrapContent) -> Array[String]:
	var errors: Array[String] = []
	var level_01 := _find_level(catalog.levels, "level_01")
	var level_02 := _find_level(catalog.levels, "level_02")
	var level_08 := _find_level(catalog.levels, "level_08_damavand")
	if level_01 == null:
		errors.append("missing level_01")
	elif level_01.waves.size() != WAVES_PER_LEVEL:
		errors.append("level_01 wave count mismatch")
	if level_02 == null:
		errors.append("missing level_02")
	elif level_02.waves.size() < 2 or level_02.waves[1].spawn_groups.size() < 2:
		errors.append("level_02 wave 2 should have multiple spawn groups")
	if level_08 == null:
		errors.append("missing level_08_damavand")
	elif level_08.waves.is_empty():
		errors.append("level_08_damavand has no waves")
	elif level_08.waves[0].spawn_groups.is_empty():
		errors.append("level_08_damavand wave 1 has no spawn groups")
	elif level_08.waves[0].spawn_groups[0].get("enemy_id") != "enemy_zahhak_serpent_guard":
		errors.append("level_08_damavand wave 1 should start with enemy_zahhak_serpent_guard")
	return errors


static func _check_boss_factory() -> Array[String]:
	var errors: Array[String] = []
	if BossControllerFactory.create("enemy_thirst_manifest") == null:
		errors.append("BossControllerFactory failed for enemy_thirst_manifest")
	if BossControllerFactory.create("enemy_azhdaha") == null:
		errors.append("BossControllerFactory failed for enemy_azhdaha")
	return errors


static func _find_level(levels: Array, level_id: String) -> LevelData:
	for l in levels:
		if l is LevelData and l.level_id == level_id:
			return l
	return null
