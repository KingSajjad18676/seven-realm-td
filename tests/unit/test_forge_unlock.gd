extends GutTest


func before_each() -> void:
	SaveSystem.test_reset_to_defaults()


func test_unlock_spends_tower_material() -> void:
	SaveSystem.add_material("iron_serpent", 30)
	assert_false(SaveSystem.is_tower_in_pool("tower_flame_archer"))
	assert_true(ForgeService.can_unlock_tower("tower_flame_archer"))
	assert_true(ForgeService.unlock_tower_to_pool("tower_flame_archer"))
	assert_true(SaveSystem.is_tower_in_pool("tower_flame_archer"))
	assert_eq(SaveSystem.get_material("iron_serpent"), 6)


func test_starter_towers_seeded_on_new_save() -> void:
	for tid in SaveSystem.STARTER_TOWER_IDS:
		assert_true(SaveSystem.is_tower_in_pool(tid))
