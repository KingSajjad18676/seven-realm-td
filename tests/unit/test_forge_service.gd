extends GutTest


func before_each() -> void:
	SaveSystem.test_reset_to_defaults()


func test_cost_for_next_level() -> void:
	assert_eq(ForgeService.cost_for_next_level("tower_archer"), 8)
	SaveSystem.set_tower_forge("tower_archer", {"level": 5, "elite_level": 0})
	assert_eq(ForgeService.cost_for_next_level("tower_archer"), 24)


func test_cost_for_next_elite_requires_normal_max() -> void:
	SaveSystem.set_tower_forge("tower_archer", {"level": 10, "elite_level": 0})
	assert_eq(ForgeService.cost_for_next_elite("tower_archer"), 0)
	SaveSystem.set_tower_forge("tower_archer", {"level": 30, "elite_level": 0})
	assert_eq(ForgeService.cost_for_next_elite("tower_archer"), 40)


func test_damage_and_range_mult() -> void:
	SaveSystem.set_tower_forge("tower_archer", {"level": 11, "elite_level": 0})
	assert_almost_eq(ForgeService.get_damage_mult("tower_archer"), 1.4, 0.001)
	assert_almost_eq(ForgeService.get_range_mult("tower_archer"), 1.1, 0.001)


func test_visual_tier_and_elite() -> void:
	SaveSystem.set_tower_forge("tower_archer", {"level": 15, "elite_level": 0})
	assert_eq(ForgeService.get_visual_tier("tower_archer"), 2)
	SaveSystem.set_tower_forge("tower_archer", {"level": 30, "elite_level": 5})
	assert_eq(ForgeService.get_visual_tier("tower_archer"), 4)


func test_can_enter_damavand_requires_elite_tower() -> void:
	assert_false(ForgeService.can_enter_damavand())
	for tid in ForgeService.get_all_forgeable_tower_ids():
		SaveSystem.set_tower_forge(tid, {"level": 30, "elite_level": 5})
		break
	assert_true(ForgeService.can_enter_damavand())
