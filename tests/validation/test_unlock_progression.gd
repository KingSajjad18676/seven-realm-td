extends GutTest


func before_each() -> void:
	SaveSystem.test_reset_to_defaults()


func test_level_01_unlocks_level_02() -> void:
	SaveSystem.unlock_levels_after_clear("level_01")
	assert_true(SaveSystem.is_level_unlocked("level_02"))


func test_level_07_unlocks_damavand() -> void:
	SaveSystem.unlock_levels_after_clear("level_07")
	assert_true(SaveSystem.is_level_unlocked("level_08_damavand"))


func test_tutorial_level_does_not_unlock_campaign() -> void:
	SaveSystem.unlock_levels_after_clear("level_00_tutorial")
	assert_false(SaveSystem.is_level_unlocked("level_02"))


func test_progression_chain() -> void:
	var chain := [
		["level_01", "level_02"],
		["level_02", "level_03"],
		["level_03", "level_04"],
		["level_04", "level_05"],
		["level_05", "level_06"],
		["level_06", "level_07"],
		["level_07", "level_08_damavand"],
	]
	for step in chain:
		SaveSystem.unlock_levels_after_clear(step[0])
		assert_true(SaveSystem.is_level_unlocked(step[1]), "%s should unlock %s" % [step[0], step[1]])
