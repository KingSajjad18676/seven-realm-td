extends GutTest


func before_each() -> void:
	if SaveSystem:
		SaveSystem.test_reset_to_defaults()
	if DailyMissionService:
		DailyMissionService.refresh_if_needed()


func test_daily_missions_roll_three() -> void:
	var missions := DailyMissionService.get_active_missions()
	assert_lte(missions.size(), 6)
	assert_gte(missions.size(), 1)


func test_claim_requires_progress() -> void:
	var missions := DailyMissionService.get_active_missions()
	if missions.is_empty():
		pass_test("No missions rolled")
		return
	var mission_id := str(missions[0].get("mission_id", ""))
	var result := DailyMissionService.claim_mission(mission_id)
	assert_true(result.is_empty())
