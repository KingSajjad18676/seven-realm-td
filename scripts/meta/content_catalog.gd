class_name ContentCatalog
extends RefCounted

## Runtime design data for M4–M8 campaign and roguelite content.

const HORDE_WAVES_TO_CLEAR := 15
const BROTHERS_WAVES_TO_CLEAR := 20
const KHAN_HORDE_LEVELS: Array[String] = [
	"level_01", "level_02", "level_03", "level_04",
	"level_05", "level_06", "level_07", "level_08_damavand",
]
const THRONE_ARENA_LEVEL_ID := "level_throne_arena"
const THRONE_SPAWN_COUNT := 10


static func build_bootstrap() -> BootstrapContent:
	var content := BootstrapContent.new()
	content.towers = build_towers()
	content.enemies = build_enemies()
	content.heroes = build_heroes()
	content.fate_cards = build_fate_cards()
	content.spells = build_spells()
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
		t.unlock_material_cost = 0

	var flame_archer := TowerData.new()
	flame_archer.tower_id = "tower_flame_archer"
	flame_archer.display_name = "Flame Archer"
	flame_archer.family = GameEnums.TowerFamily.ARCHER
	flame_archer.build_cost = 100
	flame_archer.damage = 18.0
	flame_archer.attack_rate = 1.6
	flame_archer.range = 155.0
	flame_archer.applies_burn = true
	flame_archer.color = Color(1.0, 0.45, 0.15)
	flame_archer.max_level = 3
	flame_archer.forge_material_id = "iron_serpent"
	flame_archer.forge_material_name = "Serpent Star Iron"
	flame_archer.unlock_material_cost = 24

	var volcano_ram := TowerData.new()
	volcano_ram.tower_id = "tower_volcano_ram"
	volcano_ram.display_name = "Volcano Ram"
	volcano_ram.family = GameEnums.TowerFamily.HEAVY
	volcano_ram.build_cost = 120
	volcano_ram.damage = 34.0
	volcano_ram.attack_rate = 0.65
	volcano_ram.range = 125.0
	volcano_ram.applies_burn = true
	volcano_ram.armor_break = true
	volcano_ram.color = Color(0.85, 0.35, 0.2)
	volcano_ram.max_level = 3
	volcano_ram.forge_material_id = "iron_volcano"
	volcano_ram.forge_material_name = "Volcano Star Iron"
	volcano_ram.unlock_material_cost = 30

	var zahhak_serpent := TowerData.new()
	zahhak_serpent.tower_id = "tower_zahhak_serpent"
	zahhak_serpent.display_name = "Serpent Spire"
	zahhak_serpent.family = GameEnums.TowerFamily.SACRED_FIRE
	zahhak_serpent.attack_behavior = GameEnums.AttackBehavior.TWIN
	zahhak_serpent.build_cost = 150
	zahhak_serpent.damage = 18.0
	zahhak_serpent.attack_rate = 1.15
	zahhak_serpent.range = 165.0
	zahhak_serpent.applies_burn = false
	zahhak_serpent.color = Color(0.55, 0.12, 0.28)
	zahhak_serpent.max_level = 3

	var barracks := TowerData.new()
	barracks.tower_id = "tower_rostam_barracks"
	barracks.display_name = "Rostam Tahmtan Barracks"
	barracks.family = GameEnums.TowerFamily.BARRACKS
	barracks.attack_behavior = GameEnums.AttackBehavior.BARRACKS
	barracks.build_cost = 140
	barracks.damage = 0.0
	barracks.attack_rate = 0.0
	barracks.range = 0.0
	barracks.spawn_unit_id = "unit_zabul_vanguard"
	barracks.upgraded_unit_id = "unit_bull_mace_bearer"
	barracks.max_units = 2
	barracks.unit_respawn_cooldown = 6.0
	barracks.rally_offset = Vector2(0, -45)
	barracks.color = Color(0.45, 0.35, 0.25)
	barracks.max_level = 3

	return [archer, sacred, heavy, control, flame_archer, volcano_ram, zahhak_serpent, barracks]


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
	lion.forge_material_drop = 30
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

	var mirage := EnemyData.new()
	mirage.enemy_id = "enemy_mirage_shade"
	mirage.display_name = "Mirage Shade"
	mirage.tags = ["runner"]
	mirage.max_hp = 18.0
	mirage.move_speed = 130.0
	mirage.gold_reward = 5
	mirage.color = Color(0.7, 0.75, 0.9)

	var salt_brute := EnemyData.new()
	salt_brute.enemy_id = "enemy_salt_crust_brute"
	salt_brute.display_name = "Salt-Crust Brute"
	salt_brute.tags = ["brute"]
	salt_brute.max_hp = 110.0
	salt_brute.move_speed = 48.0
	salt_brute.armor = 7.0
	salt_brute.gold_reward = 16
	salt_brute.scale = 1.25
	salt_brute.color = Color(0.75, 0.7, 0.55)

	var serpent := EnemyData.new()
	serpent.enemy_id = "enemy_canyon_serpent"
	serpent.display_name = "Canyon Serpent"
	serpent.tags = ["regen"]
	serpent.max_hp = 55.0
	serpent.move_speed = 75.0
	serpent.gold_reward = 9
	serpent.forge_material_id = "iron_serpent"
	serpent.forge_material_drop = 2
	serpent.forge_material_drop_chance = 0.4
	serpent.color = Color(0.35, 0.6, 0.35)

	var hound := EnemyData.new()
	hound.enemy_id = "enemy_scorched_hound"
	hound.display_name = "Scorched Hound"
	hound.tags = ["runner"]
	hound.max_hp = 32.0
	hound.move_speed = 115.0
	hound.gold_reward = 7
	hound.color = Color(0.6, 0.35, 0.2)

	var illusion := EnemyData.new()
	illusion.enemy_id = "enemy_illusion_attendant"
	illusion.display_name = "Illusion Attendant"
	illusion.tags = ["decoy"]
	illusion.max_hp = 15.0
	illusion.move_speed = 100.0
	illusion.gold_reward = 4
	illusion.color = Color(0.8, 0.6, 0.95)

	var feast_shade := EnemyData.new()
	feast_shade.enemy_id = "enemy_feast_shade"
	feast_shade.display_name = "Feast Shade"
	feast_shade.tags = ["corruptor"]
	feast_shade.max_hp = 38.0
	feast_shade.move_speed = 68.0
	feast_shade.gold_reward = 9
	feast_shade.sacred_fire_reward = 1
	feast_shade.corruption_pressure = 14.0
	feast_shade.color = Color(0.55, 0.25, 0.65)

	var raider := EnemyData.new()
	raider.enemy_id = "enemy_mountain_raider"
	raider.display_name = "Mountain Raider"
	raider.tags = ["runner"]
	raider.max_hp = 24.0
	raider.move_speed = 125.0
	raider.gold_reward = 6
	raider.color = Color(0.5, 0.4, 0.35)

	var m_archer := EnemyData.new()
	m_archer.enemy_id = "enemy_mountain_archer"
	m_archer.display_name = "Mountain Archer"
	m_archer.tags = ["ranged"]
	m_archer.max_hp = 30.0
	m_archer.move_speed = 85.0
	m_archer.armor = 1.0
	m_archer.gold_reward = 8
	m_archer.color = Color(0.45, 0.5, 0.4)

	var div_inf := EnemyData.new()
	div_inf.enemy_id = "enemy_div_infantry"
	div_inf.display_name = "Div Infantry"
	div_inf.tags = ["div", "grunt"]
	div_inf.max_hp = 45.0
	div_inf.move_speed = 80.0
	div_inf.armor = 2.0
	div_inf.gold_reward = 8
	div_inf.color = Color(0.3, 0.25, 0.4)

	var div_brute := EnemyData.new()
	div_brute.enemy_id = "enemy_div_brute"
	div_brute.display_name = "Div Brute"
	div_brute.tags = ["div", "brute"]
	div_brute.max_hp = 130.0
	div_brute.move_speed = 50.0
	div_brute.armor = 8.0
	div_brute.gold_reward = 18
	div_brute.forge_material_id = "iron_volcano"
	div_brute.forge_material_drop = 3
	div_brute.forge_material_drop_chance = 0.35
	div_brute.scale = 1.35
	div_brute.color = Color(0.25, 0.2, 0.35)

	var div_corruptor := EnemyData.new()
	div_corruptor.enemy_id = "enemy_div_corruptor"
	div_corruptor.display_name = "Div Corruptor"
	div_corruptor.tags = ["div", "corruptor"]
	div_corruptor.max_hp = 48.0
	div_corruptor.move_speed = 65.0
	div_corruptor.gold_reward = 11
	div_corruptor.sacred_fire_reward = 2
	div_corruptor.corruption_pressure = 22.0
	div_corruptor.color = Color(0.35, 0.15, 0.45)

	var thrall := EnemyData.new()
	thrall.enemy_id = "enemy_white_div_thrall"
	thrall.display_name = "White Div Thrall"
	thrall.tags = ["grunt"]
	thrall.max_hp = 22.0
	thrall.move_speed = 105.0
	thrall.gold_reward = 5
	thrall.color = Color(0.85, 0.85, 0.9)

	var boulder := EnemyData.new()
	boulder.enemy_id = "enemy_cavern_boulder_brute"
	boulder.display_name = "Cavern Boulder Brute"
	boulder.tags = ["brute"]
	boulder.max_hp = 160.0
	boulder.move_speed = 38.0
	boulder.armor = 10.0
	boulder.gold_reward = 20
	boulder.scale = 1.5
	boulder.color = Color(0.55, 0.5, 0.52)

	var serpent_guard := EnemyData.new()
	serpent_guard.enemy_id = "enemy_zahhak_serpent_guard"
	serpent_guard.display_name = "Serpent Guard"
	serpent_guard.tags = ["corruptor", "guard"]
	serpent_guard.max_hp = 70.0
	serpent_guard.move_speed = 60.0
	serpent_guard.armor = 3.0
	serpent_guard.gold_reward = 12
	serpent_guard.corruption_pressure = 16.0
	serpent_guard.color = Color(0.4, 0.15, 0.2)

	var chainbreaker := EnemyData.new()
	chainbreaker.enemy_id = "enemy_chainbreaker_div"
	chainbreaker.display_name = "Chainbreaker Div"
	chainbreaker.tags = ["div", "brute", "guard"]
	chainbreaker.max_hp = 140.0
	chainbreaker.move_speed = 52.0
	chainbreaker.armor = 7.0
	chainbreaker.gold_reward = 16
	chainbreaker.color = Color(0.45, 0.1, 0.15)

	return [
		jackal, boar, corruptor, lion, thirst, azhdaha, sorceress, olad, arzhang, white_div, zahhak,
		mirage, salt_brute, serpent, hound, illusion, feast_shade, raider, m_archer,
		div_inf, div_brute, div_corruptor, thrall, boulder, serpent_guard, chainbreaker,
	]


static func build_heroes() -> Array[HeroData]:
	var rostam := HeroData.new()
	rostam.hero_id = "rostam"
	rostam.display_name = "Rostam"
	rostam.max_hp = 220.0
	rostam.move_speed = 190.0
	rostam.attack_damage = 32.0
	rostam.attack_rate = 1.35
	rostam.attack_arc_range = 64.0
	rostam.heavy_damage = 52.0
	rostam.heavy_cooldown = 4.5
	rostam.heavy_radius = 82.0
	rostam.dodge_cooldown = 2.2
	rostam.dodge_distance = 100.0
	rostam.skill_damage = 60.0
	rostam.tether_radius = 120.0
	rostam.secondary_skill_id = "rostam_naft"
	rostam.naft_max_charges = 2
	rostam.naft_refill_sec = 20.0
	rostam.naft_max_active = 2
	rostam.naft_slick_half_length = 70.0
	rostam.naft_slow_mult = 0.35
	rostam.naft_oil_duration_sec = 35.0
	rostam.naft_blaze_duration_sec = 3.5
	rostam.naft_blaze_burst_damage = 40.0
	rostam.naft_blaze_dps = 22.0
	rostam.color = Color(0.2, 0.45, 0.85)
	rostam.sprite_path = VisualAssetLoader.khan1_sprite("rostam")

	var zal := HeroData.new()
	zal.hero_id = "zal"
	zal.display_name = "Zal"
	zal.max_hp = 180.0
	zal.move_speed = 200.0
	zal.attack_damage = 26.0
	zal.attack_rate = 1.5
	zal.attack_arc_range = 58.0
	zal.heavy_damage = 40.0
	zal.heavy_cooldown = 4.0
	zal.dodge_cooldown = 2.0
	zal.dodge_distance = 110.0
	zal.skill_id = "zal_foresight"
	zal.skill_cooldown = 10.0
	zal.skill_damage = 45.0
	zal.tether_radius = 140.0
	zal.color = Color(0.55, 0.75, 0.9)

	var sohrab := HeroData.new()
	sohrab.hero_id = "sohrab"
	sohrab.display_name = "Sohrab"
	sohrab.max_hp = 200.0
	sohrab.move_speed = 205.0
	sohrab.attack_damage = 34.0
	sohrab.attack_rate = 1.25
	sohrab.attack_arc_range = 60.0
	sohrab.heavy_damage = 58.0
	sohrab.heavy_cooldown = 5.5
	sohrab.dodge_cooldown = 2.8
	sohrab.dodge_distance = 90.0
	sohrab.skill_id = "sohrab_rage"
	sohrab.skill_cooldown = 12.0
	sohrab.skill_damage = 70.0
	sohrab.tether_radius = 120.0
	sohrab.color = Color(0.9, 0.45, 0.25)
	sohrab.sprite_path = VisualAssetLoader.khan1_sprite("sohrab")

	return [rostam, zal, sohrab]


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


static func build_spells() -> Array[SpellData]:
	var spells: Array[SpellData] = []
	var defs := [
		["spell_gold_rush", "Gold Rush", "Instant +40 gold.", SpellData.Rarity.COMMON, 20, 45.0, "gold_bonus", 40.0, "spell_gold_rush"],
		["spell_purify_blast", "Purify Blast", "Cleanse all pressured regions.", SpellData.Rarity.UNCOMMON, 35, 60.0, "cleanse_all", 1.0, "spell_purify_blast"],
		["spell_morale_surge", "Morale Surge", "+15 Morale instantly.", SpellData.Rarity.UNCOMMON, 30, 50.0, "morale_bonus", 15.0, "spell_morale_surge"],
		["spell_fire_storm", "Fire Storm", "Burn all active enemies.", SpellData.Rarity.RARE, 60, 90.0, "damage_all", 80.0, "spell_fire_storm"],
		["spell_tower_overcharge", "Tower Overcharge", "+40% tower damage for 12s.", SpellData.Rarity.RARE, 55, 75.0, "tower_buff", 1.4, "spell_tower_overcharge"],
		["spell_serpent_bane", "Serpent Bane", "Massive burst vs bosses and brutes.", SpellData.Rarity.LEGENDARY, 100, 120.0, "boss_burst", 250.0, "spell_serpent_bane"],
	]
	for d in defs:
		var s := SpellData.new()
		s.spell_id = d[0]
		s.display_name = d[1]
		s.description = d[2]
		s.rarity = d[3]
		s.forge_token_cost = d[4]
		s.cooldown_seconds = d[5]
		s.effect_type = d[6]
		s.effect_value = d[7]
		s.store_product_id = d[8]
		spells.append(s)
	return spells


static func khan_index(level_id: String) -> int:
	match level_id:
		"level_01":
			return 1
		"level_02":
			return 2
		"level_03":
			return 3
		"level_04":
			return 4
		"level_05":
			return 5
		"level_06":
			return 6
		"level_07":
			return 7
		"level_08_damavand":
			return 8
		_:
			return 1


static func khan_difficulty(level_id: String) -> Dictionary:
	var idx := khan_index(level_id)
	var base_hp := 1.0 + float(idx - 1) * 0.12
	var base_speed := 1.0 + float(idx - 1) * 0.04
	var base_count := 1.0 + float(idx - 1) * 0.15
	if idx < ForgeService.FORGE_GATE_START_INDEX:
		return {
			"hp_mult": base_hp,
			"speed_mult": base_speed,
			"count_mult": base_count,
		}
	var forge_dmg := ForgeService.expected_damage_mult_for_level(level_id) if ForgeService else 1.28
	return {
		"hp_mult": base_hp * forge_dmg,
		"speed_mult": base_speed + float(idx - 2) * 0.02,
		"count_mult": base_count * (1.0 + (forge_dmg - 1.0) * 0.5),
	}


static func get_horde_roster(level_id: String) -> Array[String]:
	match level_id:
		"level_01":
			return ["enemy_jackal", "enemy_boar", "enemy_corruptor"]
		"level_02":
			return ["enemy_mirage_shade", "enemy_salt_crust_brute", "enemy_corruptor"]
		"level_03":
			return ["enemy_canyon_serpent", "enemy_scorched_hound", "enemy_corruptor"]
		"level_04":
			return ["enemy_illusion_attendant", "enemy_feast_shade", "enemy_corruptor"]
		"level_05":
			return ["enemy_mountain_raider", "enemy_mountain_archer", "enemy_boar"]
		"level_06":
			return ["enemy_div_infantry", "enemy_div_brute", "enemy_div_corruptor"]
		"level_07":
			return ["enemy_white_div_thrall", "enemy_cavern_boulder_brute", "enemy_div_corruptor"]
		"level_08_damavand":
			return ["enemy_zahhak_serpent_guard", "enemy_chainbreaker_div", "enemy_div_brute"]
		_:
			return ["enemy_jackal", "enemy_boar", "enemy_corruptor"]


static func forge_tokens_for_victory(level_id: String, horde: bool) -> int:
	var idx := khan_index(level_id)
	if horde:
		return 10 + idx * 5
	return 5 + idx * 3


static func available_towers_for_level(level_id: String, include_zahhak: bool) -> Array[String]:
	var ids := _starter_towers()
	if include_zahhak:
		ids.append("tower_zahhak_serpent")
	return ids


static func build_levels() -> Array[LevelData]:
	return [
		build_tutorial(),
		build_khan_level("level_01", "Labour 1 — Lion and Rakhsh", 32, 18, 150, 4, "enemy_lion_boss", _khan1_path(), false),
		build_khan_level("level_02", "Labour 2 — Desert of Thirst", 36, 20, 160, 5, "enemy_thirst_manifest", _khan2_path(), false),
		build_khan_level("level_03", "Labour 3 — Azhdaha Canyon", 40, 22, 170, 5, "enemy_azhdaha", _khan3_path(), true),
		build_khan_level("level_04", "Labour 4 — Sorceress Feast", 42, 24, 175, 5, "enemy_sorceress", _khan4_path(), true),
		build_khan_level("level_05", "Labour 5 — Olad Camp", 48, 27, 180, 6, "enemy_olad_champion", _khan5_path(), true),
		build_khan_level("level_06", "Labour 6 — Arzhang Fortress", 52, 30, 185, 6, "enemy_arzhang_div", _khan6_path(), true),
		build_khan_level("level_07", "Labour 7 — White Div Cavern", 56, 32, 190, 6, "enemy_white_div", _khan7_path(), true),
		build_khan_level("level_08_damavand", "Damavand Binding", 64, 36, 200, 8, "enemy_zahhak", _damavand_path(), true),
		build_throne_arena_level(),
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
	level.map_sprite_path = VisualAssetLoader.map_sprite("level_00_tutorial")
	level.waves = _tutorial_waves()
	level.minimap_bounds = MapCameraUtils.compute_world_bounds(level)
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
	level.available_tower_ids = available_towers_for_level(id, false)
	level.region_ids = _region_ids_large_map() if large_cam else _region_ids_north_south()
	level.spawn_position = path[0]
	level.gate_position = path[path.size() - 1]
	level.path_points = path
	level.boss_enemy_id = boss_id
	level.uses_large_map_camera = large_cam
	level.map_sprite_path = VisualAssetLoader.map_sprite(id)
	if large_cam:
		level.camera_anchors = [Vector2(640, 360), Vector2(900, 400), Vector2(400, 320)]
	level.waves = CampaignWaveTemplates.generate(id, boss_id)
	level.block_size = 10
	level.default_objective_id = _default_objective_for(id)
	level.labour_mode_id = LabourModeFactory.labour_mode_id_for_level(id)
	level.minimap_bounds = MapCameraUtils.compute_world_bounds(level)
	if id in ["level_05", "level_06", "level_07", "level_08_damavand"]:
		_add_secondary_lane(level, path, 70.0)
	return level


static func _add_secondary_lane(level: LevelData, path: Array[Vector2], lateral_offset: float) -> void:
	level.ensure_routes_migrated()
	level.ensure_spawns_migrated()
	var route2 := PathRouteData.new()
	route2.route_id = "route_2"
	for pt in path:
		route2.points.append(pt + Vector2(lateral_offset * 0.35, lateral_offset))
	level.path_routes.append(route2)
	var spawn2 := SpawnPointData.new()
	spawn2.spawn_id = "spawn_2"
	spawn2.position = route2.points[0]
	spawn2.route_id = "route_2"
	level.spawn_points.append(spawn2)


static func get_hero_skill_catalog() -> Array[Dictionary]:
	return [
		{
			"skill_id": "rostam_charge",
			"display_name": "Rostam Charge",
			"description": "Dash strike — damage and slow nearby foes.",
			"unlock_level_id": "",
		},
		{
			"skill_id": "zal_foresight",
			"display_name": "Zal Foresight",
			"description": "Mark enemies and boost hero and tower damage briefly.",
			"unlock_level_id": "level_02",
		},
		{
			"skill_id": "sohrab_rage",
			"display_name": "Sohrab Rage",
			"description": "Furious burst — heavy damage at a health cost.",
			"unlock_level_id": "level_03",
		},
	]


static func is_valid_hero_skill_id(skill_id: String) -> bool:
	for entry in get_hero_skill_catalog():
		if str(entry.get("skill_id", "")) == skill_id:
			return true
	return false


static func _starter_towers() -> Array[String]:
	return ["tower_archer", "tower_sacred_fire", "tower_heavy", "tower_control"]


static func get_starter_tower_ids() -> Array[String]:
	return _starter_towers()


static func get_unlockable_tower_ids() -> Array[String]:
	var ids: Array[String] = []
	for t in build_towers():
		if t.unlock_material_cost > 0 and t.forge_material_id != "":
			ids.append(t.tower_id)
	return ids


static func get_material_for_tower(tower_id: String) -> String:
	if ContentRegistry:
		var td := ContentRegistry.get_tower(tower_id)
		if td:
			return td.forge_material_id
	return ""


static func _region_ids_north_south() -> Array[String]:
	return ["region_north", "region_south"]


static func _region_ids_large_map() -> Array[String]:
	return ["region_north", "region_south", "region_east"]


static func _region_ids_compass() -> Array[String]:
	return ["region_north", "region_east", "region_south", "region_west"]


static func build_radial_routes(center: Vector2, radius: float, count: int) -> Dictionary:
	var routes: Array[PathRouteData] = []
	var spawns: Array[SpawnPointData] = []
	for i in count:
		var angle := (TAU * float(i)) / float(count)
		var spawn_pos := center + Vector2(cos(angle), sin(angle)) * radius
		var route_id := "route_throne_%d" % i
		var spawn_id := "spawn_throne_%d" % i
		var route := PathRouteData.new()
		route.route_id = route_id
		route.points = [spawn_pos, center]
		routes.append(route)
		var spawn := SpawnPointData.new()
		spawn.spawn_id = spawn_id
		spawn.position = spawn_pos
		spawn.route_id = route_id
		spawns.append(spawn)
	return {"routes": routes, "spawns": spawns}


static func build_throne_arena_level() -> LevelData:
	var center := Vector2(640, 360)
	var radial := build_radial_routes(center, 520.0, THRONE_SPAWN_COUNT)
	var level := LevelData.new()
	level.level_id = THRONE_ARENA_LEVEL_ID
	level.display_name = "Defend the Throne"
	level.grid_width = 32
	level.grid_height = 18
	level.starting_gold = 180
	level.starting_lives = 18
	level.starting_sacred_fire = 5
	level.hero_id = "rostam"
	level.available_tower_ids = _starter_towers()
	level.region_ids = _region_ids_compass()
	level.gate_position = center
	level.spawn_position = radial["spawns"][0].position as Vector2
	level.path_routes = radial["routes"] as Array[PathRouteData]
	level.spawn_points = radial["spawns"] as Array[SpawnPointData]
	level.path_points = (radial["routes"][0] as PathRouteData).points.duplicate()
	level.build_spot_positions = _throne_build_spots(center)
	level.default_objective_id = "obj_survive_waves"
	level.labour_mode_id = ""
	level.block_size = 10
	level.camera_anchors = [center]
	level.minimap_bounds = MapCameraUtils.compute_world_bounds(level)
	level.waves = []
	return level


static func _throne_build_spots(center: Vector2) -> Array[Vector2]:
	var spots: Array[Vector2] = []
	var ring_radius := 160.0
	for i in 10:
		var angle := (TAU * float(i)) / 10.0
		spots.append(center + Vector2(cos(angle), sin(angle)) * ring_radius)
	return spots


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


static func wave_count_for(level_id: String) -> int:
	var idx := khan_index(level_id)
	if idx <= 0:
		return 5
	return 20 + idx * 10


## Extra multipliers applied on the campaign final wave boss spawn (after Khan difficulty).
static func final_boss_hp_mult(level_id: String) -> float:
	var idx := khan_index(level_id)
	return 2.0 + float(maxi(0, idx - 1)) * 0.25


static func final_boss_damage_mult(level_id: String) -> float:
	var idx := khan_index(level_id)
	return 1.6 + float(maxi(0, idx - 1)) * 0.2


static func mini_boss_for(level_id: String) -> String:
	match level_id:
		"level_01":
			return "enemy_boar"
		"level_02":
			return "enemy_salt_crust_brute"
		"level_03":
			return "enemy_canyon_serpent"
		"level_04":
			return "enemy_feast_shade"
		"level_05":
			return "enemy_mountain_raider"
		"level_06":
			return "enemy_div_brute"
		"level_07":
			return "enemy_cavern_boulder_brute"
		"level_08_damavand":
			return "enemy_chainbreaker_div"
		_:
			return "enemy_boar"


static func _generate_campaign_waves(level_id: String, boss_id: String) -> Array[WaveData]:
	return CampaignWaveTemplates.generate(level_id, boss_id)


static func _spawn_groups(entries: Array) -> Array[Dictionary]:
	var groups: Array[Dictionary] = []
	for entry in entries:
		groups.append(entry as Dictionary)
	return groups


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


static func build_ally_units() -> Array[AllyUnitData]:
	var vanguard := AllyUnitData.new()
	vanguard.unit_id = "unit_zabul_vanguard"
	vanguard.display_name = "Zabul Vanguard"
	vanguard.max_hp = 180.0
	vanguard.damage = 20.0
	vanguard.attack_rate = 0.9
	vanguard.move_speed = 110.0
	vanguard.cleave_radius = 48.0
	vanguard.magic_fire_resist = 0.35
	vanguard.color = Color(0.35, 0.45, 0.55)

	var mace := AllyUnitData.new()
	mace.unit_id = "unit_bull_mace_bearer"
	mace.display_name = "Bull-Mace Bearer"
	mace.max_hp = 220.0
	mace.damage = 32.0
	mace.attack_rate = 0.65
	mace.move_speed = 95.0
	mace.armor_shatter = 3.0
	mace.stun_seconds = 0.8
	mace.color = Color(0.5, 0.38, 0.28)
	return [vanguard, mace]


static func get_ally_unit(unit_id: String) -> AllyUnitData:
	for unit in build_ally_units():
		if unit.unit_id == unit_id:
			return unit
	return null


static func build_companions() -> Array[CompanionData]:
	var cheetah := CompanionData.new()
	cheetah.companion_id = "companion_royal_cheetah"
	cheetah.display_name = "Royal Cheetah"
	cheetah.description = "Auto-scavenges Star Iron drops and banks them at Rostam."
	cheetah.behavior = CompanionData.Behavior.CHEETAH_SCAVENGER
	cheetah.move_speed = 320.0
	cheetah.color = Color(0.9, 0.65, 0.2)

	var simurgh := CompanionData.new()
	simurgh.companion_id = "companion_simurgh_fledgling"
	simurgh.display_name = "Simurgh Fledgling"
	simurgh.description = "Orbits Rostam; every 15s restores 50 regional light."
	simurgh.behavior = CompanionData.Behavior.SIMURGH_ORBITER
	simurgh.orbit_radius = 70.0
	simurgh.orbit_speed = 0.8
	simurgh.pulse_interval_sec = 15.0
	simurgh.pulse_light_amount = 50
	simurgh.color = Color(0.95, 0.85, 0.45)

	var zavareh := CompanionData.new()
	zavareh.companion_id = "companion_zavareh"
	zavareh.display_name = "Zavareh"
	zavareh.description = "Guards the Gate and blocks enemies that slip past your towers."
	zavareh.behavior = CompanionData.Behavior.ZAVAREH_GATE_GUARD
	zavareh.move_speed = 130.0
	zavareh.gate_offset = Vector2(-55, 0)
	zavareh.max_hp = 240.0
	zavareh.attack_damage = 24.0
	zavareh.attack_rate = 0.85
	zavareh.color = Color(0.35, 0.5, 0.75)

	return [cheetah, simurgh, zavareh]


static func build_equipment_sets() -> Array[EquipmentSetData]:
	var sets: Array[EquipmentSetData] = []
	sets.append(_make_equipment_set(
		"set_rakhsh_vigor", "Rakhsh's Vigor",
		"rakhsh_dash_knockdown", "Dashing through light enemies knocks them down.",
		"rakhsh_tower_range_near_hero", "Towers placed near Rostam gain +10% attack range.",
		"rakhsh_spectral_horse", "Heavy attacks summon a spectral horse that tramples and stuns foes for 3 seconds."
	))
	sets.append(_make_equipment_set(
		"set_thirst_turan", "Thirst of Turan",
		"thirst_forge_token_drop", "Enemies have a 10% higher chance to drop Forge Tokens.",
		"thirst_tower_refund", "Building a tower refunds 10% of its Gold cost.",
		"thirst_tower_sell_bonus", "Once per map, selling a tower grants 200% Gold value and heals the Gate by 1 Life."
	))
	sets.append(_make_equipment_set(
		"set_azhdaha_scale", "Scale of the Azhdaha",
		"azhdaha_melee_burn", "Rostam's melee attacks apply a 3-second burn.",
		"azhdaha_fire_extra_shot", "All Fire Towers shoot an extra projectile.",
		"azhdaha_fire_nova", "Below 20% HP, Rostam erupts in a fire nova that vaporizes non-boss enemies."
	))
	sets.append(_make_equipment_set(
		"set_mazandaran_venom", "Venom of Mazandaran",
		"mazandaran_melee_slow", "Rostam's attacks slow enemy movement speed by 30%.",
		"mazandaran_archer_armor_break", "Enemies shot by Archer Towers lose 20% of their armor rating.",
		"mazandaran_toxic_explosion", "Enemies dying from poison or debuffs explode into a toxic cloud that stops movement for 2 seconds."
	))
	sets.append(_make_equipment_set(
		"set_kaveh_iron", "Iron of Kaveh",
		"kaveh_periodic_shield", "Rostam passively generates a small shield every 10 seconds.",
		"kaveh_heavy_vs_brute", "Heavy Artillery towers deal double damage to Div Brutes.",
		"kaveh_gate_rebuild", "If the Gate is destroyed, Kaveh's magic rebuilds it with 1 Life for all your Gold."
	))
	sets.append(_make_equipment_set(
		"set_arzhang_fury", "Arzhang's Fury",
		"arzhang_cleave", "Rostam's melee attacks hit in a 180-degree cleave arc.",
		"arzhang_combat_tower_haste", "While Rostam is in combat, all towers fire 15% faster.",
		"arzhang_blood_frenzy", "Activating Sacred Tether sends Rostam into Blood Frenzy: 2x attack speed and invincible for 5 seconds."
	))
	sets.append(_make_equipment_set(
		"set_simurgh_talon", "Simurgh's Talon",
		"simurgh_cleanse_discount", "Sacred Fire costs for cleansing regions are reduced by half.",
		"simurgh_beam_cleanse", "Tower attack beams illuminate the map, acting as free cleansers.",
		"simurgh_wings_dash_cleanse", "Rostam can dash across the map to any corrupted zone and instantly cleanse it for free."
	))
	return sets


static func _make_equipment_set(
	id: String,
	name: String,
	rule2: String,
	desc2: String,
	rule3: String,
	desc3: String,
	rule4: String,
	desc4: String
) -> EquipmentSetData:
	var s := EquipmentSetData.new()
	s.set_id = id
	s.set_name = name
	s.two_piece_rule_id = rule2
	s.two_piece_description = desc2
	s.three_piece_rule_id = rule3
	s.three_piece_description = desc3
	s.four_piece_rule_id = rule4
	s.four_piece_description = desc4
	return s


static func build_equipment_pieces() -> Array[EquipmentPieceData]:
	var pieces: Array[EquipmentPieceData] = []
	# Set 1 — Rakhsh's Vigor
	pieces.append(_equip_piece("equip_rakhsh_lion_bone_club", "The Lion-Bone Club", "set_rakhsh_vigor",
		EquipmentPieceData.SlotType.WEAPON, EquipmentPieceData.DropSource.KHAN_BOSS, "level_01",
		{"hero_melee_damage_mult": 1.05}))
	pieces.append(_equip_piece("equip_rakhsh_mantle_steed", "Mantle of the Steed", "set_rakhsh_vigor",
		EquipmentPieceData.SlotType.ARMOR, EquipmentPieceData.DropSource.KHAN_BOSS, "level_01",
		{"hero_move_speed_mult": 1.10}))
	pieces.append(_equip_piece("equip_rakhsh_mane_helm", "Mane of Rakhsh", "set_rakhsh_vigor",
		EquipmentPieceData.SlotType.HELM, EquipmentPieceData.DropSource.DAILY_MISSION, "",
		{"hero_max_hp_mult": 1.05}))
	pieces.append(_equip_piece("equip_rakhsh_golden_horseshoe", "The Golden Horseshoe", "set_rakhsh_vigor",
		EquipmentPieceData.SlotType.TALISMAN, EquipmentPieceData.DropSource.DAILY_MISSION, "",
		{"hero_dash_distance_mult": 1.10}))
	# Set 2 — Thirst of Turan
	pieces.append(_equip_piece("equip_thirst_blade_mirage", "Blade of the Mirage", "set_thirst_turan",
		EquipmentPieceData.SlotType.WEAPON, EquipmentPieceData.DropSource.KHAN_BOSS, "level_02",
		{"hero_attack_rate_mult": 1.05}))
	pieces.append(_equip_piece("equip_thirst_desert_cloak", "Desert Wanderer's Cloak", "set_thirst_turan",
		EquipmentPieceData.SlotType.ARMOR, EquipmentPieceData.DropSource.KHAN_BOSS, "level_02",
		{"hero_dodge_chance": 0.10}))
	pieces.append(_equip_piece("equip_thirst_sun_cowl", "Sun-Bleached Cowl", "set_thirst_turan",
		EquipmentPieceData.SlotType.HELM, EquipmentPieceData.DropSource.DAILY_MISSION, "",
		{"sacred_fire_drain_mult": 0.95}))
	pieces.append(_equip_piece("equip_thirst_diviner_coin", "The Water Diviner's Coin", "set_thirst_turan",
		EquipmentPieceData.SlotType.TALISMAN, EquipmentPieceData.DropSource.DAILY_MISSION, "",
		{"gold_magnet_radius_mult": 1.50}))
	# Set 3 — Scale of Azhdaha
	pieces.append(_equip_piece("equip_azhdaha_dragons_fang", "The Dragon's Fang", "set_azhdaha_scale",
		EquipmentPieceData.SlotType.WEAPON, EquipmentPieceData.DropSource.KHAN_BOSS, "level_03",
		{"hero_armor_pierce": 0.10}))
	pieces.append(_equip_piece("equip_azhdaha_charred_scalemail", "Charred Scalemail", "set_azhdaha_scale",
		EquipmentPieceData.SlotType.ARMOR, EquipmentPieceData.DropSource.KHAN_BOSS, "level_03",
		{"hero_env_fire_immune": true, "hero_env_poison_immune": true}))
	pieces.append(_equip_piece("equip_azhdaha_horns", "Horns of the Azhdaha", "set_azhdaha_scale",
		EquipmentPieceData.SlotType.HELM, EquipmentPieceData.DropSource.DAILY_MISSION, "",
		{"hero_melee_damage_mult": 1.05}))
	pieces.append(_equip_piece("equip_azhdaha_smoldering_ember", "Smoldering Ember", "set_azhdaha_scale",
		EquipmentPieceData.SlotType.TALISMAN, EquipmentPieceData.DropSource.DAILY_MISSION, "",
		{"tower_fire_damage_mult": 1.05}))
	# Set 4 — Venom of Mazandaran
	pieces.append(_equip_piece("equip_mazandaran_witch_dagger", "The Witch-Hunter's Dagger", "set_mazandaran_venom",
		EquipmentPieceData.SlotType.WEAPON, EquipmentPieceData.DropSource.KHAN_BOSS, "level_04",
		{"hero_attack_rate_mult": 1.15}))
	pieces.append(_equip_piece("equip_mazandaran_shroud", "Shroud of Illusions", "set_mazandaran_venom",
		EquipmentPieceData.SlotType.ARMOR, EquipmentPieceData.DropSource.KHAN_BOSS, "level_04",
		{"hero_ranged_evasion": 0.10}))
	pieces.append(_equip_piece("equip_mazandaran_enchantress_veil", "The Enchantress Veil", "set_mazandaran_venom",
		EquipmentPieceData.SlotType.HELM, EquipmentPieceData.DropSource.DAILY_MISSION, "",
		{"sacred_fire_max_bonus": 0.05}))
	pieces.append(_equip_piece("equip_mazandaran_black_blood", "Vial of Black Blood", "set_mazandaran_venom",
		EquipmentPieceData.SlotType.TALISMAN, EquipmentPieceData.DropSource.DAILY_MISSION, "",
		{"corruption_duration_bonus": 2.0}))
	# Set 5 — Iron of Kaveh
	pieces.append(_equip_piece("equip_kaveh_blacksmith_hammer", "The Blacksmith's Hammer", "set_kaveh_iron",
		EquipmentPieceData.SlotType.WEAPON, EquipmentPieceData.DropSource.KHAN_BOSS, "level_05",
		{"hero_knockback_mult": 2.50}))
	pieces.append(_equip_piece("equip_kaveh_commander_plate", "Heavy Commander's Plate", "set_kaveh_iron",
		EquipmentPieceData.SlotType.ARMOR, EquipmentPieceData.DropSource.KHAN_BOSS, "level_05",
		{"hero_move_speed_mult": 0.90, "hero_max_hp_mult": 1.50}))
	pieces.append(_equip_piece("equip_kaveh_vanguard_bascinet", "The Vanguard Bascinet", "set_kaveh_iron",
		EquipmentPieceData.SlotType.HELM, EquipmentPieceData.DropSource.DAILY_MISSION, "",
		{"hero_stagger_immune": true}))
	pieces.append(_equip_piece("equip_kaveh_anvil_stone", "The Anvil Stone", "set_kaveh_iron",
		EquipmentPieceData.SlotType.TALISMAN, EquipmentPieceData.DropSource.DAILY_MISSION, "",
		{"heavy_tower_cost_mult": 0.90}))
	# Set 6 — Arzhang's Fury
	pieces.append(_equip_piece("equip_arzhang_demon_cleaver", "The Demon-Cleaver", "set_arzhang_fury",
		EquipmentPieceData.SlotType.WEAPON, EquipmentPieceData.DropSource.KHAN_BOSS, "level_06",
		{"hero_melee_damage_mult": 1.15}))
	pieces.append(_equip_piece("equip_arzhang_flayed_cuirass", "Flayed Skin Cuirass", "set_arzhang_fury",
		EquipmentPieceData.SlotType.ARMOR, EquipmentPieceData.DropSource.KHAN_BOSS, "level_06",
		{"hero_damage_speed_boost": true}))
	pieces.append(_equip_piece("equip_arzhang_skull_vanguard", "Skull of the Vanguard", "set_arzhang_fury",
		EquipmentPieceData.SlotType.HELM, EquipmentPieceData.DropSource.DAILY_MISSION, "",
		{"hero_crit_chance": 0.10}))
	pieces.append(_equip_piece("equip_arzhang_bloodied_tusks", "Bloodied Tusks", "set_arzhang_fury",
		EquipmentPieceData.SlotType.TALISMAN, EquipmentPieceData.DropSource.DAILY_MISSION, "",
		{"hero_lifesteal_on_kill": 0.01}))
	# Set 7 — Simurgh's Talon
	pieces.append(_equip_piece("equip_simurgh_sun_spear", "The Sun-Forged Spear", "set_simurgh_talon",
		EquipmentPieceData.SlotType.WEAPON, EquipmentPieceData.DropSource.KHAN_BOSS, "level_07",
		{"hero_light_damage": true}))
	pieces.append(_equip_piece("equip_simurgh_guardian_feathers", "Feathers of the Guardian", "set_simurgh_talon",
		EquipmentPieceData.SlotType.ARMOR, EquipmentPieceData.DropSource.KHAN_BOSS, "level_07",
		{"hero_trap_immune": true}))
	pieces.append(_equip_piece("equip_simurgh_crown_alborz", "Crown of Alborz", "set_simurgh_talon",
		EquipmentPieceData.SlotType.HELM, EquipmentPieceData.DropSource.DAILY_MISSION, "",
		{"sacred_fire_regen": 1.0}))
	pieces.append(_equip_piece("equip_simurgh_white_div_horn", "The White Div's Horn", "set_simurgh_talon",
		EquipmentPieceData.SlotType.TALISMAN, EquipmentPieceData.DropSource.DAILY_MISSION, "",
		{"corruption_drain_mult": 0.50}))
	return pieces


static func _equip_piece(
	id: String,
	name: String,
	set_id: String,
	slot: EquipmentPieceData.SlotType,
	source: EquipmentPieceData.DropSource,
	level_id: String,
	stats: Dictionary
) -> EquipmentPieceData:
	var p := EquipmentPieceData.new()
	p.piece_id = id
	p.display_name = name
	p.set_id = set_id
	p.slot_type = slot
	p.drop_source = source
	p.drop_level_id = level_id
	p.stat_modifiers = stats
	return p


static func build_daily_mission_definitions() -> Array[DailyMissionDefinition]:
	var defs: Array[DailyMissionDefinition] = []
	defs.append(_mission_def("mission_slayer_demons", "Slayer of Demons: Kill 500 Divs total across any game mode.", 500, "total_div_kills"))
	defs.append(_mission_def("mission_untouchable", "The Untouchable Pahlavan: Complete any map wave without taking Hero damage.", 1, "untouchable_wave"))
	defs.append(_mission_def("mission_master_architect", "Master Architect: Build 20 fully upgraded towers in a single run.", 20, "run_max_upgraded_towers"))
	defs.append(_mission_def("mission_hoarder", "Hoarder of Turan: Accumulate 5,000 Gold in a single run without spending it.", 5000, "run_peak_unspent_gold"))
	defs.append(_mission_def("mission_light_bringer", "Light Bringer: Cleanse 15 Corrupted regions using Sacred Fire.", 15, "total_cleanses"))
	defs.append(_mission_def("mission_pristine_defense", "Pristine Defense: Defeat a Boss wave without losing a single Gate Life.", 1, "pristine_boss_wave"))
	defs.append(_mission_def("mission_blacksmith_patron", "The Blacksmith's Patron: Spend 1,000 Forge Tokens on meta-upgrades.", 1000, "total_forge_tokens_spent"))
	defs.append(_mission_def("mission_close_quarters", "Close Quarters: Kill 50 enemies using only Rostam's melee attacks.", 50, "run_melee_kills"))
	defs.append(_mission_def("mission_rain_of_arrows", "Rain of Arrows: Deal 10,000 damage using only Archer Towers.", 10000, "run_archer_damage"))
	defs.append(_mission_def("mission_earth_shaker", "Earth Shaker: Stun 100 enemies using Heavy Towers or Hero Abilities.", 100, "run_stun_count"))
	return defs


static func _mission_def(id: String, desc: String, target: int, key: String) -> DailyMissionDefinition:
	var m := DailyMissionDefinition.new()
	m.mission_id = id
	m.description = desc
	m.goal_target = target
	m.tracking_key = key
	return m


static func equipment_pieces_for_level(level_id: String) -> Array[EquipmentPieceData]:
	var out: Array[EquipmentPieceData] = []
	for p in build_equipment_pieces():
		if p.drop_level_id == level_id and p.is_boss_drop():
			out.append(p)
	return out


static func daily_helm_talisman_pool() -> Array[EquipmentPieceData]:
	var out: Array[EquipmentPieceData] = []
	for p in build_equipment_pieces():
		if p.is_daily_drop():
			out.append(p)
	return out
