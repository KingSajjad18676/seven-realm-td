extends GutTest


func before_each() -> void:
	if SaveSystem:
		SaveSystem.test_reset_to_defaults()


func test_seen_hints_default_empty() -> void:
	assert_false(SaveSystem.has_seen_hint("hint_tower_panel"))


func test_mark_hint_seen_persists() -> void:
	SaveSystem.mark_hint_seen("hint_tower_panel")
	assert_true(SaveSystem.has_seen_hint("hint_tower_panel"))
	assert_false(SaveSystem.has_seen_hint("hint_forge"))


func test_seen_hints_survives_legacy_save_without_key() -> void:
	SaveSystem.test_replace_data({"save_version": 4, "tutorial_completed": false})
	assert_false(SaveSystem.has_seen_hint("hint_early_call"))
	SaveSystem.mark_hint_seen("hint_early_call")
	assert_true(SaveSystem.has_seen_hint("hint_early_call"))
