extends GutTest


func test_v1_migrates_to_v4() -> void:
	var v1 := {
		"save_version": 1,
		"tutorial_completed": false,
		"unlocked_levels": ["level_00_tutorial"],
	}
	var migrated := SaveMigration.migrate(v1, 5)
	assert_eq(int(migrated.get("save_version", 0)), 5)
	assert_true(migrated.has("star_iron"))
	assert_true(migrated.has("tower_forge"))
	assert_true(migrated.has("replay_stats"))
	assert_true(migrated.has("accessibility"))
	assert_true(migrated.has("roguelite_run"))
	assert_true(migrated.has("hunt_best_binding"))


func test_v3_adds_hunt_fields_only() -> void:
	var v3 := {
		"save_version": 3,
		"star_iron": {},
		"tower_forge": {},
		"replay_stats": {},
		"accessibility": SaveMigration.default_accessibility(),
		"daily_tale": {},
		"endless_best": 0,
	}
	var migrated := SaveMigration.migrate(v3, 4)
	assert_eq(int(migrated.get("save_version", 0)), 4)
	assert_true(migrated.has("roguelite_run"))
	assert_eq(int(migrated.get("hunt_best_binding", -1)), 0)


func test_cosmetic_entitlements_preserved() -> void:
	var data := {
		"save_version": 1,
		"cosmetic_entitlements": ["skin_rostam_gold"],
	}
	var migrated := SaveMigration.migrate(data, 4)
	assert_has(migrated.get("cosmetic_entitlements", []), "skin_rostam_gold")


func test_already_v5_unchanged_version() -> void:
	var v5 := {
		"save_version": 5,
		"forge_tokens": 42,
		"spells_owned": ["spell_gold_rush"],
	}
	var migrated := SaveMigration.migrate(v5, 5)
	assert_eq(int(migrated.get("save_version", 0)), 5)
	assert_eq(int(migrated.get("forge_tokens", 0)), 42)
	assert_has(migrated.get("spells_owned", []), "spell_gold_rush")
