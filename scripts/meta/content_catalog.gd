class_name ContentCatalog
extends RefCounted

## Runtime design data for M4–M8 campaign and roguelite content.


static func build_bootstrap() -> BootstrapContent:
	var content := BootstrapContent.new()
	content.towers = build_towers()
	content.enemies = build_enemies()
	content.heroes = build_heroes()
	content.fate_cards = build_fate_cards()
	content.levels = build_levels()
	return content


static func build_towers() -> Array[TowerData]:
	var archer := TowerData.new()
	archer.tower_id = "tower_archer"
	archer.display_name = "Archer Tower"
	archer.family = GameEnums.TowerFamily.ARCHER
	archer.build_cost = 50
	archer.damage = 14.0
	archer.attack_rate = 1.4
	archer.range = 150.0
	archer.color = Color(0.2, 0.7, 0.6)
	archer.forge_material_id = "iron_falcon"
	archer.forge_material_name = "Falcon Star Iron"
	archer.sprite_path = VisualAssetLoader.khan1_sprite("tower_archer")

	var sacred := TowerData.new()
	sacred.tower_id = "tower_sacred_fire"
	sacred.display_name = "Sacred Fire"
	sacred.family = GameEnums.TowerFamily.SACRED_FIRE
	sacred.build_cost = 65
	sacred.damage = 10.0
	sacred.attack_rate = 1.0
	sacred.range = 130.0
	sacred.applies_burn = true
	sacred.color = Color(1.0, 0.55, 0.2)
	sacred.forge_material_id = "iron_ember"
	sacred.forge_material_name = "Ember Star Iron"
	sacred.sprite_path = VisualAssetLoader.khan1_sprite("tower_sacred_fire")

	var heavy := TowerData.new()
	heavy.tower_id = "tower_heavy"
	heavy.display_name = "Heavy Tower"
	heavy.family = GameEnums.TowerFamily.HEAVY
	heavy.build_cost = 80
	heavy.damage = 28.0
	heavy.attack_rate = 0.55
	heavy.range = 120.0
	heavy.armor_break = true
	heavy.color = Color(0.5, 0.45, 0.4)
	heavy.forge_material_id = "iron_anvil"
	heavy.forge_material_name = "Anvil Star Iron"
	heavy.sprite_path = VisualAssetLoader.khan1_sprite("tower_heavy")

	var control := TowerData.new()
	control.tower_id = "tower_control"
	control.display_name = "Control Tower"
	control.family = GameEnums.TowerFamily.CONTROL
	control.build_cost = 70
	control.damage = 6.0
	control.attack_rate = 0.9
	control.range = 140.0
	control.applies_slow = true
	control.color = Color(0.35, 0.5, 0.85)
	control.forge_material_id = "iron_frost"
	control.forge_material_name = "Frost Star Iron"
	control.sprite_path = VisualAssetLoader.khan1_sprite("tower_control")

	for t in [archer, sacred, heavy, control]:
		t.max_level = 3
	return [archer, sacred, heavy, control]


static func build_enemies() -> Array[EnemyData]:
	var jackal := EnemyData.new()
	jackal.enemy_id = "enemy_jackal"
	jackal.display_name = "Corrupted Jackal"
	jackal.tags = ["grunt"]
	jackal.max_hp = 28.0
	jackal.move_speed = 95.0
	jackal.gold_reward = 6
	jackal.forge_material_id = "iron_falcon"
	jackal.forge_material_drop = 2
	jackal.color = Color(0.75, 0.35, 0.2)
	jackal.sprite_path = VisualAssetLoader.khan1_sprite("enemy_jackal")

	var boar := EnemyData.new()
	boar.enemy_id = "enemy_boar"
	boar.display_name = "Corrupted Boar"
	boar.tags = ["brute"]
	boar.max_hp = 90.0
	boar.move_speed = 55.0
	boar.armor = 4.0
	boar.gold_reward = 14
	boar.forge_material_id = "iron_anvil"
	boar.forge_material_drop = 3
	boar.color = Color(0.55, 0.3, 0.25)
	boar.scale = 1.3
	boar.sprite_path = VisualAssetLoader.khan1_sprite("enemy_boar")

	var corruptor := EnemyData.new()
	corruptor.enemy_id = "enemy_corruptor"
	corruptor.display_name = "Corruptor"
	corruptor.tags = ["corruptor"]
	corruptor.max_hp = 40.0
	corruptor.move_speed = 70.0
	corruptor.gold_reward = 10
	corruptor.sacred_fire_reward = 2
	corruptor.forge_material_id = "iron_ember"
	corruptor.forge_material_drop = 3
	corruptor.corruption_pressure = 18.0
	corruptor.color = Color(0.45, 0.2, 0.55)
	corruptor.sprite_path = VisualAssetLoader.khan1_sprite("enemy_corruptor")

	var lion := EnemyData.new()
	lion.enemy_id = "enemy_lion_boss"
	lion.display_name = "Lion of the First Khan"
	lion.tags = ["boss"]
	lion.max_hp = 620.0
	lion.move_speed = 45.0
	lion.armor = 6.0
	lion.gold_reward = 80
	lion.forge_material_id = "iron_frost"
	lion.forge_material_drop = 25
	lion.is_boss = true
	lion.color = Color(0.85, 0.7, 0.25)
	lion.scale = 2.0
	lion.sprite_path = VisualAssetLoader.khan1_sprite("enemy_lion_boss")

	var thirst := EnemyData.new()
	thirst.enemy_id = "enemy_thirst_manifest"
	thirst.display_name = "Manifestation of Thirst"
	thirst.tags = ["boss"]
	thirst.max_hp = 720.0
	thirst.move_speed = 50.0
	thirst.armor = 5.0
	thirst.gold_reward = 90
	thirst.is_boss = true
	thirst.color = Color(0.55, 0.65, 0.85)
	thirst.scale = 1.8

	var azhdaha := EnemyData.new()
	azhdaha.enemy_id = "enemy_azhdaha"
	azhdaha.display_name = "Azhdaha"
	azhdaha.tags = ["boss"]
	azhdaha.max_hp = 900.0
	azhdaha.move_speed = 40.0
	azhdaha.armor = 8.0
	azhdaha.gold_reward = 100
	azhdaha.is_boss = true
	azhdaha.color = Color(0.3, 0.55, 0.25)
	azhdaha.scale = 2.2

	var sorceress := EnemyData.new()
	sorceress.enemy_id = "enemy_sorceress"
	sorceress.display_name = "Sorceress"
	sorceress.tags = ["boss"]
	sorceress.max_hp = 800.0
	sorceress.move_speed = 55.0
	sorceress.gold_reward = 95
	sorceress.is_boss = true
	sorceress.color = Color(0.7, 0.35, 0.75)

	var olad := EnemyData.new()
	olad.enemy_id = "enemy_olad_champion"
	olad.display_name = "Olad Champion"
	olad.tags = ["boss"]
	olad.max_hp = 850.0
	olad.move_speed = 60.0
	olad.armor = 4.0
	olad.gold_reward = 100
	olad.is_boss = true
	olad.color = Color(0.6, 0.45, 0.35)

	var arzhang := EnemyData.new()
	arzhang.enemy_id = "enemy_arzhang_div"
	arzhang.display_name = "Arzhang Div"
	arzhang.tags = ["boss"]
	arzhang.max_hp = 1100.0
	arzhang.move_speed = 38.0
	arzhang.armor = 10.0
	arzhang.gold_reward = 120
	arzhang.is_boss = true
	arzhang.color = Color(0.25, 0.2, 0.35)
	arzhang.scale = 2.4

	var white_div := EnemyData.new()
	white_div.enemy_id = "enemy_white_div"
	white_div.display_name = "Div-e Sepid"
	white_div.tags = ["boss"]
	white_div.max_hp = 1200.0
	white_div.move_speed = 42.0
	white_div.armor = 9.0
	white_div.gold_reward = 130
	white_div.is_boss = true
	white_div.color = Color(0.9, 0.9, 0.95)
	white_div.scale = 2.5

	var zahhak := EnemyData.new()
	zahhak.enemy_id = "enemy_zahhak"
	zahhak.display_name = "Zahhak"
	zahhak.tags = ["boss", "finale"]
	zahhak.max_hp = 2000.0
	zahhak.move_speed = 35.0
	zahhak.armor = 12.0
	zahhak.gold_reward = 200
	zahhak.is_boss = true
	zahhak.color = Color(0.5, 0.1, 0.15)
	zahhak.scale = 3.0

	return [jackal, boar, corruptor, lion, thirst, azhdaha, sorceress, olad, arzhang, white_div, zahhak]


static func build_heroes() -> Array[HeroData]:
	var rostam := HeroData.new()
	rostam.hero_id = "rostam"
	rostam.display_name = "Rostam"
	rostam.max_hp = 220.0
	rostam.move_speed = 190.0
	rostam.attack_damage = 28.0
	rostam.skill_damage = 60.0
	rostam.tether_radius = 120.0
	rostam.color = Color(0.2, 0.45, 0.85)
	rostam.sprite_path = VisualAssetLoader.khan1_sprite("rostam")

	var zal := HeroData.new()
	zal.hero_id = "zal"
	zal.display_name = "Zal"
	zal.max_hp = 180.0
	zal.move_speed = 200.0
	zal.attack_damage = 22.0
	zal.skill_id = "zal_foresight"
	zal.skill_cooldown = 10.0
	zal.skill_damage = 45.0
	zal.tether_radius = 140.0
	zal.color = Color(0.55, 0.75, 0.9)

	return [rostam, zal]


static func build_fate_cards() -> Array[FateCardData]:
	var cards: Array[FateCardData] = []
	var defs := [
		["card_flame_of_azar", "Flame of Azar", "+15% tower damage. Enemies +8% HP.", 1.15, 1.08, 0, 0, 0.0],
		["card_golden_bounty", "Golden Bounty", "+30 gold. Corruption +10%.", 1.0, 1.0, 30, 0, 0.1],
		["card_sacred_wind", "Sacred Wind", "+2 Sacred Fire.", 1.0, 1.0, 0, 2, 0.0],
		["card_iron_rain", "Iron Rain", "+20% attack speed feel (+10% dmg). Enemies +5% speed.", 1.1, 1.05, 0, 0, 0.0],
		["card_derafsh_oath", "Derafsh Oath", "+1 Morale burst. Corruption +5%.", 1.05, 1.0, 0, 1, 0.05],
		["card_qanat_blessing", "Qanat Blessing", "Control towers +slow. Gold -10 next waves.", 1.0, 1.0, -10, 0, 0.0],
		["card_lion_s_legacy", "Lion's Legacy", "+40 gold if boss wave next.", 1.0, 1.0, 40, 0, 0.0],
		["card_twilight_pact", "Twilight Pact", "+3 Sacred Fire. Enemy HP +12%.", 1.0, 1.12, 0, 3, 0.0],
	]
	for d in defs:
		var c := FateCardData.new()
		c.card_id = d[0]
		c.title = d[1]
		c.description = d[2]
		c.boon_attack_mult = d[3]
		c.curse_enemy_hp_mult = d[4]
		c.boon_gold_bonus = d[5]
		c.boon_sacred_fire_bonus = d[6]
		c.curse_corruption_rate = d[7]
		cards.append(c)
	return cards


static func build_levels() -> Array[LevelData]:
	return [
		build_tutorial(),
		build_khan_level("level_01", "Khan 1 — Lion and Rakhsh", 32, 18, 150, 4, "enemy_lion_boss", _khan1_path(), false),
		build_khan_level("level_02", "Khan 2 — Desert of Thirst", 36, 20, 160, 5, "enemy_thirst_manifest", _khan2_path(), false),
		build_khan_level("level_03", "Khan 3 — Azhdaha Canyon", 40, 22, 170, 5, "enemy_azhdaha", _khan3_path(), true),
		build_khan_level("level_04", "Khan 4 — Sorceress Feast", 42, 24, 175, 5, "enemy_sorceress", _khan4_path(), true),
		build_khan_level("level_05", "Khan 5 — Olad Camp", 48, 27, 180, 6, "enemy_olad_champion", _khan5_path(), true),
		build_khan_level("level_06", "Khan 6 — Arzhang Fortress", 52, 30, 185, 6, "enemy_arzhang_div", _khan6_path(), true),
		build_khan_level("level_07", "Khan 7 — White Div Cavern", 56, 32, 190, 6, "enemy_white_div", _khan7_path(), true),
		build_khan_level("level_08_damavand", "Damavand Binding", 64, 36, 200, 8, "enemy_zahhak", _damavand_path(), true),
	]


static func build_tutorial() -> LevelData:
	var level := LevelData.new()
	level.level_id = "level_00_tutorial"
	level.display_name = "Sacred Fire Training"
	level.is_tutorial = true
	level.grid_width = 32
	level.grid_height = 18
	level.starting_gold = 200
	level.starting_lives = 25
	level.starting_sacred_fire = 8
	level.hero_id = "rostam"
	level.available_tower_ids = _starter_towers()
	level.region_ids = _region_ids_north_south()
	level.spawn_position = Vector2(80, 360)
	level.gate_position = Vector2(1180, 360)
	level.path_points = _khan1_path()
	level.build_spot_positions = [Vector2(320, 300), Vector2(520, 220), Vector2(700, 300)]
	level.waves = _tutorial_waves()
	return level


static func build_khan_level(
	id: String,
	name: String,
	gw: int,
	gh: int,
	gold: int,
	sf: int,
	boss_id: String,
	path: Array[Vector2],
	large_cam: bool
) -> LevelData:
	var level := LevelData.new()
	level.level_id = id
	level.display_name = name
	level.grid_width = gw
	level.grid_height = gh
	level.starting_gold = gold
	level.starting_lives = 20
	level.starting_sacred_fire = sf
	level.hero_id = "rostam" if id == "level_01" else ("zal" if id in ["level_02", "level_03"] else "rostam")
	level.available_tower_ids = _starter_towers()
	level.region_ids = _region_ids_large_map() if large_cam else _region_ids_north_south()
	level.spawn_position = path[0]
	level.gate_position = path[path.size() - 1]
	level.path_points = path
	level.boss_enemy_id = boss_id
	level.uses_large_map_camera = large_cam
	level.map_sprite_path = VisualAssetLoader.map_sprite(id)
	if large_cam:
		level.camera_anchors = [Vector2(640, 360), Vector2(900, 400), Vector2(400, 320)]
	var pad_count := 4 if not large_cam else 6
	level.build_spot_positions = _pads_along_path(path, pad_count)
	level.waves = _campaign_waves_for_khan(id, boss_id)
	level.default_objective_id = _default_objective_for(id)
	return level


static func _starter_towers() -> Array[String]:
	return ["tower_archer", "tower_sacred_fire", "tower_heavy", "tower_control"]


static func _region_ids_north_south() -> Array[String]:
	return ["region_north", "region_south"]


static func _region_ids_large_map() -> Array[String]:
	return ["region_north", "region_south", "region_east"]


static func _tutorial_waves() -> Array[WaveData]:
	var waves: Array[WaveData] = []
	var w1 := WaveData.new()
	w1.wave_id = "tutorial_wave_1"
	w1.pre_wave_delay = 1.5
	w1.spawn_groups = _spawn_groups([{"enemy_id": "enemy_jackal", "count": 5}])
	waves.append(w1)
	var w2 := WaveData.new()
	w2.wave_id = "tutorial_wave_2"
	w2.pre_wave_delay = 2.0
	w2.spawn_groups = _spawn_groups([
		{"enemy_id": "enemy_jackal", "count": 4},
		{"enemy_id": "enemy_corruptor", "count": 1},
	])
	waves.append(w2)
	return waves


static func _default_objective_for(level_id: String) -> String:
	match level_id:
		"level_01":
			return "obj_no_leaks"
		"level_02":
			return "obj_cleanse_twice"
		"level_03":
			return "obj_no_leaks"
		"level_04":
			return "obj_no_hijack"
		"level_05":
			return "obj_no_leaks"
		"level_06":
			return "obj_cleanse_twice"
		"level_07":
			return "obj_no_hijack"
		"level_08_damavand":
			return "obj_cleanse_twice"
		_:
			return ""


static func _campaign_waves_for_khan(level_id: String, boss_id: String) -> Array[WaveData]:
	match level_id:
		"level_01":
			return _waves_khan_01(boss_id)
		"level_02":
			return _waves_khan_02(boss_id)
		"level_03":
			return _waves_khan_03(boss_id)
		"level_04":
			return _waves_khan_04(boss_id)
		"level_05":
			return _waves_khan_05(boss_id)
		"level_06":
			return _waves_khan_06(boss_id)
		"level_07":
			return _waves_khan_07(boss_id)
		"level_08_damavand":
			return _waves_damavand(boss_id)
		_:
			return _waves_generic(level_id, boss_id)


static func _make_wave(wave_id: String, groups: Array, delay: float = 2.0, boss: bool = false, interval: float = 0.0) -> WaveData:
	var w := WaveData.new()
	w.wave_id = wave_id
	w.pre_wave_delay = delay
	w.spawn_groups = _spawn_groups(groups)
	w.is_boss_wave = boss
	w.spawn_interval = interval
	return w


static func _spawn_groups(entries: Array) -> Array[Dictionary]:
	var groups: Array[Dictionary] = []
	for entry in entries:
		groups.append(entry as Dictionary)
	return groups


static func _waves_khan_01(boss_id: String) -> Array[WaveData]:
	return [
		_make_wave("level_01_wave_1", [{"enemy_id": "enemy_jackal", "count": 6}], 2.5),
		_make_wave("level_01_wave_2", [{"enemy_id": "enemy_jackal", "count": 8}, {"enemy_id": "enemy_boar", "count": 1}], 2.0),
		_make_wave("level_01_wave_3", [{"enemy_id": "enemy_jackal", "count": 6}, {"enemy_id": "enemy_corruptor", "count": 1}], 2.0),
		_make_wave("level_01_wave_4", [{"enemy_id": "enemy_boar", "count": 2}, {"enemy_id": "enemy_corruptor", "count": 2}], 2.0),
		_make_wave("level_01_wave_5", [{"enemy_id": boss_id, "count": 1}], 2.0, true),
	]


static func _waves_khan_02(boss_id: String) -> Array[WaveData]:
	return [
		_make_wave("level_02_wave_1", [{"enemy_id": "enemy_jackal", "count": 8}], 2.5),
		_make_wave("level_02_wave_2", [{"enemy_id": "enemy_corruptor", "count": 2}, {"enemy_id": "enemy_jackal", "count": 4}], 2.0, false, 0.35),
		_make_wave("level_02_wave_3", [{"enemy_id": "enemy_corruptor", "count": 3}, {"enemy_id": "enemy_jackal", "count": 6}], 2.0),
		_make_wave("level_02_wave_4", [{"enemy_id": "enemy_boar", "count": 2}, {"enemy_id": "enemy_corruptor", "count": 2}], 2.0),
		_make_wave("level_02_wave_5", [{"enemy_id": boss_id, "count": 1}], 2.0, true),
	]


static func _waves_khan_03(boss_id: String) -> Array[WaveData]:
	return [
		_make_wave("level_03_wave_1", [{"enemy_id": "enemy_boar", "count": 2}, {"enemy_id": "enemy_jackal", "count": 4}], 2.5),
		_make_wave("level_03_wave_2", [{"enemy_id": "enemy_boar", "count": 3}], 2.0),
		_make_wave("level_03_wave_3", [{"enemy_id": "enemy_corruptor", "count": 2}, {"enemy_id": "enemy_jackal", "count": 8}], 2.0, false, 0.25),
		_make_wave("level_03_wave_4", [{"enemy_id": "enemy_boar", "count": 3}, {"enemy_id": "enemy_corruptor", "count": 2}], 2.0),
		_make_wave("level_03_wave_5", [{"enemy_id": boss_id, "count": 1}], 2.0, true),
	]


static func _waves_khan_04(boss_id: String) -> Array[WaveData]:
	return [
		_make_wave("level_04_wave_1", [{"enemy_id": "enemy_jackal", "count": 10}], 2.5),
		_make_wave("level_04_wave_2", [{"enemy_id": "enemy_corruptor", "count": 3}, {"enemy_id": "enemy_jackal", "count": 5}], 2.0),
		_make_wave("level_04_wave_3", [{"enemy_id": "enemy_boar", "count": 2}, {"enemy_id": "enemy_corruptor", "count": 2}], 2.0),
		_make_wave("level_04_wave_4", [{"enemy_id": "enemy_jackal", "count": 12}, {"enemy_id": "enemy_corruptor", "count": 1}], 2.0, false, 0.2),
		_make_wave("level_04_wave_5", [{"enemy_id": boss_id, "count": 1}], 2.0, true),
	]


static func _waves_khan_05(boss_id: String) -> Array[WaveData]:
	return [
		_make_wave("level_05_wave_1", [{"enemy_id": "enemy_jackal", "count": 8}, {"enemy_id": "enemy_boar", "count": 2}], 2.5),
		_make_wave("level_05_wave_2", [{"enemy_id": "enemy_boar", "count": 4}], 2.0),
		_make_wave("level_05_wave_3", [{"enemy_id": "enemy_jackal", "count": 14}], 2.0, false, 0.15),
		_make_wave("level_05_wave_4", [{"enemy_id": "enemy_boar", "count": 3}, {"enemy_id": "enemy_corruptor", "count": 3}], 2.0),
		_make_wave("level_05_wave_5", [{"enemy_id": boss_id, "count": 1}], 2.0, true),
	]


static func _waves_khan_06(boss_id: String) -> Array[WaveData]:
	return [
		_make_wave("level_06_wave_1", [{"enemy_id": "enemy_boar", "count": 3}, {"enemy_id": "enemy_corruptor", "count": 1}], 2.5),
		_make_wave("level_06_wave_2", [{"enemy_id": "enemy_corruptor", "count": 4}], 2.0),
		_make_wave("level_06_wave_3", [{"enemy_id": "enemy_boar", "count": 4}, {"enemy_id": "enemy_jackal", "count": 6}], 2.0),
		_make_wave("level_06_wave_4", [{"enemy_id": "enemy_boar", "count": 2}, {"enemy_id": "enemy_corruptor", "count": 3}, {"enemy_id": "enemy_jackal", "count": 8}], 2.0),
		_make_wave("level_06_wave_5", [{"enemy_id": boss_id, "count": 1}], 2.0, true),
	]


static func _waves_khan_07(boss_id: String) -> Array[WaveData]:
	return [
		_make_wave("level_07_wave_1", [{"enemy_id": "enemy_corruptor", "count": 2}, {"enemy_id": "enemy_jackal", "count": 8}], 2.5),
		_make_wave("level_07_wave_2", [{"enemy_id": "enemy_boar", "count": 4}, {"enemy_id": "enemy_corruptor", "count": 2}], 2.0),
		_make_wave("level_07_wave_3", [{"enemy_id": "enemy_jackal", "count": 16}], 2.0, false, 0.12),
		_make_wave("level_07_wave_4", [{"enemy_id": "enemy_boar", "count": 3}, {"enemy_id": "enemy_corruptor", "count": 4}], 2.0),
		_make_wave("level_07_wave_5", [{"enemy_id": boss_id, "count": 1}], 2.0, true),
	]


static func _waves_damavand(boss_id: String) -> Array[WaveData]:
	return [
		_make_wave("level_08_wave_1", [{"enemy_id": "enemy_corruptor", "count": 4}, {"enemy_id": "enemy_jackal", "count": 6}], 2.5),
		_make_wave("level_08_wave_2", [{"enemy_id": "enemy_boar", "count": 4}, {"enemy_id": "enemy_corruptor", "count": 2}], 2.0),
		_make_wave("level_08_wave_3", [{"enemy_id": "enemy_corruptor", "count": 5}], 2.0, false, 0.3),
		_make_wave("level_08_wave_4", [{"enemy_id": "enemy_boar", "count": 3}, {"enemy_id": "enemy_jackal", "count": 12}, {"enemy_id": "enemy_corruptor", "count": 2}], 2.0),
		_make_wave("level_08_wave_5", [{"enemy_id": boss_id, "count": 1}], 2.5, true),
	]


static func _waves_generic(level_id: String, boss_id: String) -> Array[WaveData]:
	return _waves_khan_01(boss_id)


static func _pads_along_path(path: Array[Vector2], count: int) -> Array[Vector2]:
	var pads: Array[Vector2] = []
	if path.is_empty():
		return pads
	for i in range(count):
		var t := float(i + 1) / float(count + 1)
		var idx := int(t * float(path.size() - 1))
		idx = clampi(idx, 0, path.size() - 1)
		pads.append(path[idx] + Vector2(0, -60))
	return pads


static func _khan1_path() -> Array[Vector2]:
	return [
		Vector2(80, 360), Vector2(280, 360), Vector2(400, 260),
		Vector2(640, 260), Vector2(760, 360), Vector2(980, 360), Vector2(1180, 360),
	]


static func _khan2_path() -> Array[Vector2]:
	return [
		Vector2(60, 380), Vector2(300, 380), Vector2(500, 300),
		Vector2(700, 300), Vector2(900, 380), Vector2(1200, 380),
	]


static func _khan3_path() -> Array[Vector2]:
	return [
		Vector2(80, 200), Vector2(350, 200), Vector2(500, 360),
		Vector2(700, 360), Vector2(850, 200), Vector2(1100, 200), Vector2(1200, 360),
	]


static func _khan4_path() -> Array[Vector2]:
	return [
		Vector2(100, 360), Vector2(350, 480), Vector2(550, 360),
		Vector2(750, 240), Vector2(950, 360), Vector2(1150, 360),
	]


static func _khan5_path() -> Array[Vector2]:
	return [
		Vector2(80, 300), Vector2(400, 300), Vector2(600, 450),
		Vector2(800, 300), Vector2(1000, 450), Vector2(1250, 300),
	]


static func _khan6_path() -> Array[Vector2]:
	return [
		Vector2(100, 250), Vector2(400, 250), Vector2(550, 400),
		Vector2(750, 400), Vector2(900, 250), Vector2(1150, 250), Vector2(1250, 400),
	]


static func _khan7_path() -> Array[Vector2]:
	return [
		Vector2(120, 200), Vector2(450, 200), Vector2(600, 380),
		Vector2(800, 380), Vector2(950, 200), Vector2(1200, 200), Vector2(1280, 380),
	]


static func _damavand_path() -> Array[Vector2]:
	return [
		Vector2(100, 360), Vector2(400, 360), Vector2(600, 200),
		Vector2(800, 200), Vector2(1000, 360), Vector2(1200, 360), Vector2(1400, 280),
	]
