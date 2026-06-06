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
	launch.is_daily_tale = false
	launch.is_campaign_run = true
	assert_false(launch.is_campaign_mode())
	launch.is_campaign_run = false
	launch.is_brothers_mode = true
	assert_false(launch.is_campaign_mode())
	launch.is_brothers_mode = false
	launch.is_throne_defense_mode = true
	assert_false(launch.is_campaign_mode())
	launch.is_throne_defense_mode = false
	launch.is_gauntlet_mode = true
	assert_false(launch.is_campaign_mode())


func test_duplicate_launch_copies_relics() -> void:
	var launch := BattleLaunchData.new()
	launch.level_id = "level_03"
	launch.tower_relic_slots = {"tower_archer": "relic_cup_of_jamshid"}
	launch.active_relic_ids = ["relic_one"]
	launch.roguelite_node_index = 2
	var copy := launch.duplicate_launch()
	assert_eq(copy.level_id, "level_03")
	assert_eq(copy.roguelite_node_index, 2)
	assert_eq(copy.tower_relic_slots.get("tower_archer"), "relic_cup_of_jamshid")
	assert_has(copy.active_relic_ids, "relic_one")
	copy.active_relic_ids.append("relic_two")
	assert_eq(launch.active_relic_ids.size(), 1)


func test_scavenge_mode_includes_roguelite() -> void:
	var launch := BattleLaunchData.new()
	launch.is_roguelite_run = true
	assert_true(launch.is_scavenge_mode())


func test_duplicate_launch_copies_kavus_folly() -> void:
	var launch := BattleLaunchData.new()
	launch.kavus_folly_active = true
	var copy := launch.duplicate_launch()
	assert_true(copy.kavus_folly_active)
	copy.kavus_folly_active = false
	assert_true(launch.kavus_folly_active)
