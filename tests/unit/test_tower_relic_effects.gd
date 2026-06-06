extends GutTest


func test_restore_fraction_heals_at_one_life() -> void:
	var ctx := BattleTestFixtures.minimal_context(self)
	var lives := LivesController.new()
	add_child(lives)
	lives.initialize(ctx)
	ctx.lives = lives
	lives.current_lives = 18
	lives.max_lives = 20
	lives.restore_fraction(1.0)
	assert_eq(lives.current_lives, 19)
	lives.restore_fraction(1.0)
	assert_eq(lives.current_lives, 20)
	lives.restore_fraction(1.0)
	assert_eq(lives.current_lives, 20)


func test_jamshid_global_range_uses_map_bounds() -> void:
	var ctx := BattleTestFixtures.context_with_level(self)
	ctx.level_data.minimap_bounds = Rect2(0, 0, 1280, 720)
	var mods := BattleTestFixtures.attach_run_modifiers(self, ctx)
	var jamshid := RelicData.new()
	jamshid.relic_id = "relic_cup_of_jamshid"
	jamshid.slot_tower_id = "tower_archer"
	jamshid.global_targeting = true
	mods.slot_relic(jamshid, "tower_archer")
	var tower_data := TowerData.new()
	tower_data.tower_id = "tower_archer"
	tower_data.range = 120.0
	var preview := TowerController.compute_preview_range(ctx, tower_data, "region_a")
	assert_gt(preview, 1000.0)


func test_run_modifier_loads_tower_slot() -> void:
	var ctx := BattleTestFixtures.context_with_level(self)
	var mods := BattleTestFixtures.attach_run_modifiers(self, ctx)
	var jamshid := RelicData.new()
	jamshid.relic_id = "test_jamshid"
	jamshid.slot_tower_id = "tower_archer"
	jamshid.tower_attack_rate_mult = 0.5
	mods.load_slots({"tower_archer": "test_jamshid"}, [])
	mods.slotted["tower_archer"] = jamshid
	var relic := mods.get_relic_for_tower("tower_archer")
	assert_not_null(relic)
	assert_almost_eq(relic.tower_attack_rate_mult, 0.5, 0.001)
