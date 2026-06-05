extends GutTest


func test_endless_launch_is_not_campaign() -> void:
	var launch := BattleLaunchData.new()
	launch.is_endless_mode = true
	assert_false(launch.is_campaign_mode())


func test_hunt_launch_is_not_campaign() -> void:
	var launch := BattleLaunchData.new()
	launch.is_hunt_mode = true
	assert_false(launch.is_campaign_mode())


func test_horde_launch_is_not_campaign() -> void:
	var launch := BattleLaunchData.new()
	launch.is_horde_mode = true
	assert_false(launch.is_campaign_mode())


func test_plain_campaign_launch_is_campaign() -> void:
	var launch := BattleLaunchData.new()
	assert_true(launch.is_campaign_mode())


func test_non_campaign_levels_have_no_factory_mode() -> void:
	for level_id in ["level_hunt", "level_endless"]:
		assert_eq(LabourModeFactory.labour_mode_id_for_level(level_id), "")
