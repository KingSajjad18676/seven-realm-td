extends GutTest


func test_labour_mode_ids_for_campaign_levels() -> void:
	for level_id in [
		"level_01", "level_02", "level_03", "level_04",
		"level_05", "level_06", "level_07", "level_08_damavand",
	]:
		var mode_id := LabourModeFactory.labour_mode_id_for_level(level_id)
		assert_ne(mode_id, "", "Expected labour mode for %s" % level_id)
		var level := LevelData.new()
		level.level_id = level_id
		level.labour_mode_id = mode_id
		var mode := LabourModeFactory.create(level)
		assert_not_null(mode, "Factory should build %s" % mode_id)


func test_tutorial_has_no_labour_mode() -> void:
	var level := LevelData.new()
	level.level_id = "level_00_tutorial"
	level.labour_mode_id = LabourModeFactory.labour_mode_id_for_level(level.level_id)
	assert_eq(level.labour_mode_id, "")
	assert_null(LabourModeFactory.create(level))


func test_barracks_unlock_on_seventh_seal() -> void:
	SaveSystem.test_reset_to_defaults()
	for i in range(6):
		var lid := "level_0%d" % (i + 1)
		SaveSystem.mark_level_cleared(lid)
	assert_false(SaveSystem.is_tower_unlocked("tower_rostam_barracks"))
	SaveSystem.mark_level_cleared("level_07")
	assert_true(SaveSystem.is_tower_unlocked("tower_rostam_barracks"))


func test_store_unlocks_barracks() -> void:
	SaveSystem.test_reset_to_defaults()
	assert_true(StoreService.purchase("tower_rostam_barracks"))
	assert_true(SaveSystem.is_tower_unlocked("tower_rostam_barracks"))
