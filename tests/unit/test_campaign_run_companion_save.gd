extends GutTest


func test_active_companion_round_trip() -> void:
	var run := CampaignRunState.new()
	run.set_active_companion("companion_royal_cheetah")
	var restored := CampaignRunState.from_dict(run.to_dict())
	assert_eq(restored.active_companion_id, "companion_royal_cheetah")


func test_launch_data_duplicates_companion() -> void:
	var launch := BattleLaunchData.new()
	launch.active_companion_id = "companion_simurgh_fledgling"
	var copy := launch.duplicate_launch()
	assert_eq(copy.active_companion_id, "companion_simurgh_fledgling")
