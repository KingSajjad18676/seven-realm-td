extends Node

var bootstrap: BootstrapContent = null

var _towers: Dictionary = {}
var _enemies: Dictionary = {}
var _heroes: Dictionary = {}
var _waves: Dictionary = {}
var _levels: Dictionary = {}
var _fate_cards: Dictionary = {}
var _spells: Dictionary = {}
var _relics: Dictionary = {}
var _objectives: Dictionary = {}


func _ready() -> void:
	_load_bootstrap()


func reload() -> void:
	_relics.clear()
	_objectives.clear()
	_load_bootstrap()


func _load_bootstrap() -> void:
	bootstrap = ContentCatalog.build_bootstrap()
	_merge_folder_resources("res://resources/data/")
	_index_content()


func _merge_folder_resources(base_path: String) -> void:
	if not DirAccess.dir_exists_absolute(base_path):
		return
	var dir := DirAccess.open(base_path)
	if dir == null:
		return
	dir.list_dir_begin()
	var sub := dir.get_next()
	while sub != "":
		if sub != "." and sub != ".." and dir.current_is_dir():
			_load_resources_in_dir(base_path.path_join(sub))
		sub = dir.get_next()
	dir.list_dir_end()


func _load_resources_in_dir(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	var file := dir.get_next()
	while file != "":
		if file.ends_with(".tres"):
			var res: Resource = load(path.path_join(file))
			_merge_resource(res)
		file = dir.get_next()
	dir.list_dir_end()


func _merge_resource(res: Resource) -> void:
	if res is TowerData:
		bootstrap.towers.append(res)
	elif res is EnemyData:
		bootstrap.enemies.append(res)
	elif res is HeroData:
		bootstrap.heroes.append(res)
	elif res is LevelData:
		_replace_or_append_level(res)
	elif res is FateCardData:
		bootstrap.fate_cards.append(res)
	elif res is SpellData:
		bootstrap.spells.append(res)
	elif res is RelicData:
		if not bootstrap.has_method("get"):
			pass
		_relics[res.relic_id] = res
	elif res is ObjectiveData:
		_objectives[res.objective_id] = res


func _index_content() -> void:
	_towers.clear()
	_enemies.clear()
	_heroes.clear()
	_waves.clear()
	_levels.clear()
	_fate_cards.clear()
	_spells.clear()
	for t in bootstrap.towers:
		_towers[t.tower_id] = t
	for e in bootstrap.enemies:
		_enemies[e.enemy_id] = e
	for h in bootstrap.heroes:
		_heroes[h.hero_id] = h
	for w in bootstrap.waves:
		_waves[w.wave_id] = w
	for l in bootstrap.levels:
		_levels[l.level_id] = l
	for c in bootstrap.fate_cards:
		_fate_cards[c.card_id] = c
	for s in bootstrap.spells:
		_spells[s.spell_id] = s
	if _relics.is_empty():
		for r in _build_default_relics():
			_relics[r.relic_id] = r
	if _objectives.is_empty():
		for o in _build_default_objectives():
			_objectives[o.objective_id] = o
	else:
		for o in _build_default_objectives():
			if not _objectives.has(o.objective_id):
				_objectives[o.objective_id] = o


func get_tower(tower_id: String) -> TowerData:
	return _towers.get(tower_id) as TowerData


func get_enemy(enemy_id: String) -> EnemyData:
	return _enemies.get(enemy_id) as EnemyData


func get_hero(hero_id: String) -> HeroData:
	return _heroes.get(hero_id) as HeroData


func get_wave(wave_id: String) -> WaveData:
	return _waves.get(wave_id) as WaveData


func get_level(level_id: String) -> LevelData:
	return _levels.get(level_id) as LevelData


func get_fate_card(card_id: String) -> FateCardData:
	return _fate_cards.get(card_id) as FateCardData


func get_all_fate_cards() -> Array[FateCardData]:
	var out: Array[FateCardData] = []
	for c in _fate_cards.values():
		out.append(c)
	return out


func get_spell(spell_id: String) -> SpellData:
	return _spells.get(spell_id) as SpellData


func get_all_spells() -> Array[SpellData]:
	var out: Array[SpellData] = []
	for s in _spells.values():
		out.append(s)
	return out


func get_relic(relic_id: String) -> RelicData:
	return _relics.get(relic_id) as RelicData


func get_all_relics() -> Array[RelicData]:
	var out: Array[RelicData] = []
	for r in _relics.values():
		out.append(r)
	return out


func get_objective(objective_id: String) -> ObjectiveData:
	return _objectives.get(objective_id) as ObjectiveData


func get_random_objective() -> ObjectiveData:
	var keys: Array = []
	for key in _objectives.keys():
		var obj := _objectives[key] as ObjectiveData
		if obj and not obj.is_vow:
			keys.append(key)
	if keys.is_empty():
		return null
	var pick: String = keys[randi() % keys.size()]
	return _objectives[pick] as ObjectiveData


func get_all_vows() -> Array[ObjectiveData]:
	var out: Array[ObjectiveData] = []
	for o in _objectives.values():
		var obj := o as ObjectiveData
		if obj and obj.is_vow:
			out.append(obj)
	out.sort_custom(func(a: ObjectiveData, b: ObjectiveData) -> bool:
		return a.objective_id < b.objective_id
	)
	return out


func get_vow(vow_id: String) -> ObjectiveData:
	var obj := get_objective(vow_id)
	if obj and obj.is_vow:
		return obj
	return null


func _build_default_relics() -> Array[RelicData]:
	var r1 := RelicData.new()
	r1.relic_id = "relic_derafsh_fragment"
	r1.title = "Derafsh Fragment"
	r1.description = "+8% tower damage."
	r1.attack_mult = 1.08
	var r2 := RelicData.new()
	r2.relic_id = "relic_ember_coil"
	r2.title = "Ember Coil"
	r2.description = "+2 Sacred Fire, +5 Morale."
	r2.sacred_fire_bonus = 2
	r2.morale_bonus = 5
	var r3 := RelicData.new()
	r3.relic_id = "relic_qanat_stone"
	r3.title = "Qanat Stone"
	r3.description = "+8 gold each wave, -5% corruption."
	r3.gold_bonus_per_wave = 8
	r3.corruption_resist = 0.05
	return [r1, r2, r3]


func _replace_or_append_level(override: LevelData) -> void:
	for i in bootstrap.levels.size():
		var base: LevelData = bootstrap.levels[i]
		if base.level_id != override.level_id:
			continue
		_apply_level_override(base, override)
		return
	bootstrap.levels.append(override)


func _apply_level_override(base: LevelData, override: LevelData) -> void:
	if override.display_name != "":
		base.display_name = override.display_name
	if override.starting_gold > 0:
		base.starting_gold = override.starting_gold
	if override.starting_lives > 0:
		base.starting_lives = override.starting_lives
	if override.starting_sacred_fire > 0:
		base.starting_sacred_fire = override.starting_sacred_fire
	if override.hero_id != "":
		base.hero_id = override.hero_id
	if override.boss_enemy_id != "":
		base.boss_enemy_id = override.boss_enemy_id
	if override.default_objective_id != "":
		base.default_objective_id = override.default_objective_id
	if override.map_sprite_path != "":
		base.map_sprite_path = override.map_sprite_path
	if not override.waves.is_empty():
		base.waves = override.waves
	if not override.path_routes.is_empty():
		base.path_routes = override.path_routes
	if not override.spawn_points.is_empty():
		base.spawn_points = override.spawn_points
	if not override.path_points.is_empty():
		base.path_points = override.path_points
	if not override.build_spot_positions.is_empty():
		base.build_spot_positions = override.build_spot_positions
	if not override.region_ids.is_empty():
		base.region_ids = override.region_ids
	if override.spawn_position != Vector2.ZERO:
		base.spawn_position = override.spawn_position
	if override.gate_position != Vector2.ZERO:
		base.gate_position = override.gate_position
	base.ensure_routes_migrated()
	base.ensure_spawns_migrated()
	base.sync_legacy_fields()
	if not override.camera_anchors.is_empty():
		base.camera_anchors = override.camera_anchors
	if override.uses_large_map_camera:
		base.uses_large_map_camera = override.uses_large_map_camera
	if override.grid_width != 32:
		base.grid_width = override.grid_width
	if override.grid_height != 18:
		base.grid_height = override.grid_height
	base.minimap_bounds = MapCameraUtils.compute_world_bounds(base)


func _build_default_objectives() -> Array[ObjectiveData]:
	var o1 := ObjectiveData.new()
	o1.objective_id = "obj_no_leaks"
	o1.title = "Hold the Gate"
	o1.description = "Clear a wave with no leaks."
	o1.goal_type = "no_leaks"
	var o2 := ObjectiveData.new()
	o2.objective_id = "obj_cleanse_twice"
	o2.title = "Purify Twice"
	o2.description = "Cleanse two regions this run."
	o2.goal_type = "cleanse_twice"
	o2.goal_count = 2
	var o3 := ObjectiveData.new()
	o3.objective_id = "obj_no_hijack"
	o3.title = "Sacred Vigil"
	o3.description = "Never lose a tower to hijack."
	o3.goal_type = "no_hijack"
	var vows := _build_default_vows()
	vows.append_array([o1, o2, o3])
	return vows


func _build_default_vows() -> Array[ObjectiveData]:
	var vows: Array[ObjectiveData] = []
	vows.append(_make_vow(
		"vow_stillness", "Rostam's Stillness", "Do not move the hero this block.",
		"vow_no_hero_move", 1, 8, 5
	))
	vows.append(_make_vow(
		"vow_hold_upgrades", "Patience of the Smith", "Do not upgrade any tower this block.",
		"vow_no_upgrade", 1, 8, 5
	))
	vows.append(_make_vow(
		"vow_no_new_towers", "Make Do", "Do not build new towers this block.",
		"vow_no_build", 1, 10, 6
	))
	vows.append(_make_vow(
		"vow_no_sell", "Waste Nothing", "Do not sell any tower this block.",
		"vow_no_sell", 1, 8, 4
	))
	vows.append(_make_vow(
		"vow_mortal_resolve", "Mortal Resolve", "Do not use hero skills this block.",
		"vow_no_hero_skill", 1, 10, 6
	))
	vows.append(_make_vow(
		"vow_endure", "Endure the Dark", "Do not cleanse any region this block.",
		"vow_no_cleanse", 1, 10, 7
	))
	vows.append(_make_vow(
		"vow_unbroken_gate", "Unbroken Gate", "Let no enemy reach the gate this block.",
		"vow_no_leak_window", 1, 12, 8
	))
	vows.append(_make_vow(
		"vow_sacred_vigil", "Sacred Vigil", "Prevent all tower hijacks this block.",
		"vow_no_hijack_window", 2, 15, 10
	))
	return vows


func _make_vow(
	id: String,
	title: String,
	description: String,
	goal_type: String,
	sf_reward: int,
	morale_reward: int,
	penalty: int
) -> ObjectiveData:
	var v := ObjectiveData.new()
	v.objective_id = id
	v.title = title
	v.description = description
	v.goal_type = goal_type
	v.is_vow = true
	v.sacred_fire_reward = sf_reward
	v.morale_reward = morale_reward
	v.penalty_morale = penalty
	return v
