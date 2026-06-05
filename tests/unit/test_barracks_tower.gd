extends GutTest


func test_ally_units_exist() -> void:
	var vanguard := ContentCatalog.get_ally_unit("unit_zabul_vanguard")
	var mace := ContentCatalog.get_ally_unit("unit_bull_mace_bearer")
	assert_not_null(vanguard)
	assert_not_null(mace)
	assert_gt(vanguard.cleave_radius, 0.0)
	assert_gt(mace.armor_shatter, 0.0)


func test_barracks_tower_data() -> void:
	var towers := ContentCatalog.build_towers()
	var found := false
	for t in towers:
		if t.tower_id == "tower_rostam_barracks":
			found = true
			assert_eq(t.family, GameEnums.TowerFamily.BARRACKS)
			assert_eq(t.attack_behavior, GameEnums.AttackBehavior.BARRACKS)
			assert_eq(t.forge_material_id, "")
	assert_true(found)
