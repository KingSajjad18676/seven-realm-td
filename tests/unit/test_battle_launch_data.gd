extends GutTest


func test_campaign_mode_default() -> void:
	var launch := BattleLaunchData.new()
	assert_true(launch.is_campaign_mode())


func test_non_campaign_modes() -> void:
	var launch := BattleLaunchData.new()
	launch.is_roguelite_run = true
	assert_false(launch.is_campaign_mode())
	launch.is_roguelite_run = false
	launch.is_hunt_mode = true
	assert_false(launch.is_campaign_mode())
	launch.is_hunt_mode = false
	launch.is_endless_mode = true
	assert_false(launch.is_campaign_mode())
	launch.is_endless_mode = false
	launch.is_daily_tale = true
	assert_false(launch.is_campaign_mode())


func test_duplicate_launch_copies_relics() -> void:
	var launch := BattleLaunchData.new()
	launch.level_id = "level_03"
	launch.active_relic_ids = ["relic_one"]
	launch.roguelite_node_index = 2
	var copy := launch.duplicate_launch()
	assert_eq(copy.level_id, "level_03")
	assert_eq(copy.roguelite_node_index, 2)
	assert_has(copy.active_relic_ids, "relic_one")
	copy.active_relic_ids.append("relic_two")
	assert_eq(launch.active_relic_ids.size(), 1)
