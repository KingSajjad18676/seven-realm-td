extends GutTest


func test_v4_migrates_to_v5() -> void:
	var v4 := {
		"save_version": 4,
		"hunt_best_binding": 1,
		"roguelite_run": {},
	}
	var migrated := SaveMigration.migrate(v4, 5)
	assert_eq(int(migrated.get("save_version", 0)), 5)
	assert_true(migrated.has("forge_tokens"))
	assert_true(migrated.has("spells_owned"))
	assert_true(migrated.has("horde_progress"))
	assert_true(migrated.has("unlocked_towers"))
	assert_true(migrated.has("paid_entitlements"))


func test_forge_token_spend() -> void:
	SaveSystem.test_reset_to_defaults()
	SaveSystem.add_forge_tokens(30)
	assert_eq(SaveSystem.get_forge_tokens(), 30)
	assert_true(SaveSystem.spend_forge_tokens(10))
	assert_eq(SaveSystem.get_forge_tokens(), 20)
	assert_false(SaveSystem.spend_forge_tokens(100))


func test_horde_clear_unlocks_zahhak_tower() -> void:
	SaveSystem.test_reset_to_defaults()
	for level_id in ContentCatalog.KHAN_HORDE_LEVELS:
		SaveSystem.record_horde_victory(level_id, ContentCatalog.HORDE_WAVES_TO_CLEAR)
	assert_true(SaveSystem.has_all_khan_horde_clears())
	assert_true(SaveSystem.is_tower_unlocked("tower_zahhak_serpent"))


func test_khan_difficulty_scales() -> void:
	var k1 := ContentCatalog.khan_difficulty("level_01")
	var k7 := ContentCatalog.khan_difficulty("level_07")
	assert_gt(float(k7.hp_mult), float(k1.hp_mult))
	assert_gt(float(k7.count_mult), float(k1.count_mult))
