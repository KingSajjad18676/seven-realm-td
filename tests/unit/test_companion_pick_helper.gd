extends GutTest


func test_pick_pool_empty_when_companion_owned() -> void:
	var picks := CompanionPickHelper.pick_pool("companion_zavareh", 3)
	assert_true(picks.is_empty())


func test_pick_pool_returns_up_to_three() -> void:
	var picks := CompanionPickHelper.pick_pool("", 3)
	assert_lte(picks.size(), 3)
	assert_gt(picks.size(), 0)
