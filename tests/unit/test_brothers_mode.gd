extends GutTest


func test_brothers_launch_excludes_campaign_mode() -> void:
	var launch := BattleLaunchData.new()
	launch.is_brothers_mode = true
	assert_false(launch.is_campaign_mode())
	assert_true(launch.is_scavenge_mode())


func test_coop_player_sf_isolation() -> void:
	var coop := CoopPlayerManager.new()
	coop.initialize(["zal", "sohrab"], 4)
	assert_eq(coop.get_slot(0).sacred_fire, 4)
	assert_eq(coop.get_slot(1).sacred_fire, 4)
	assert_true(coop.spend_sacred_fire(0, 2))
	assert_eq(coop.get_slot(0).sacred_fire, 2)
	assert_eq(coop.get_slot(1).sacred_fire, 4)


func test_coop_material_attribution() -> void:
	var coop := CoopPlayerManager.new()
	coop.initialize(["zal", "sohrab"], 3)
	coop.add_material(1, "star_iron", 2)
	var merged := coop.get_merged_materials()
	assert_eq(int(merged.get("star_iron", 0)), 2)
	assert_eq(coop.get_slot(0).get_unbanked_materials().size(), 0)


func test_duplicate_launch_copies_brothers_fields() -> void:
	var launch := BattleLaunchData.new()
	launch.is_brothers_mode = true
	launch.coop_player_heroes = ["zal", "sohrab"]
	var copy := launch.duplicate_launch()
	assert_true(copy.is_brothers_mode)
	assert_eq(copy.coop_player_heroes, ["zal", "sohrab"])
