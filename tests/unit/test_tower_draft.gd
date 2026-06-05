extends GutTest


func test_launch_data_carries_run_towers() -> void:
	var launch := BattleLaunchData.new()
	launch.is_campaign_run = true
	launch.run_tower_ids = ["tower_archer", "tower_heavy", "tower_control"]
	var copy := launch.duplicate_launch()
	assert_eq(copy.run_tower_ids.size(), 3)
	assert_has(copy.run_tower_ids, "tower_archer")


func test_campaign_run_not_linear_campaign_mode() -> void:
	var launch := BattleLaunchData.new()
	launch.is_campaign_run = true
	assert_false(launch.is_campaign_mode())
	assert_true(launch.is_scavenge_mode())
