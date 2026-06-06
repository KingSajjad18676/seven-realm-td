extends GutTest


func test_v1_migrates_to_v4() -> void:
	var v1 := {
		"save_version": 1,
		"tutorial_completed": false,
		"unlocked_levels": ["level_00_tutorial"],
	}
	var migrated := SaveMigration.migrate(v1, 6)
	assert_eq(int(migrated.get("save_version", 0)), 6)
	assert_true(migrated.has("campaign_run"))
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


func test_v7_migrates_legacy_relic_ids() -> void:
	var data := {
		"save_version": 6,
		"campaign_run": {
			"relic_ids": ["relic_cup_of_jamshid"],
		},
	}
	var migrated := SaveMigration.migrate(data, 7)
	assert_eq(int(migrated.get("save_version", 0)), 7)
	var run: Dictionary = migrated["campaign_run"]
	assert_false(run.has("relic_ids"))
	assert_eq(run["tower_relic_slots"].get("tower_archer"), "relic_cup_of_jamshid")


func test_v7_migrates_to_v8_gauntlet_best() -> void:
	var v7 := {
		"save_version": 7,
		"campaign_run": {},
	}
	var migrated := SaveMigration.migrate(v7, 8)
	assert_eq(int(migrated.get("save_version", 0)), 8)
	assert_true(migrated.has("gauntlet_best"))
	var best: Dictionary = migrated["gauntlet_best"]
	assert_eq(int(best.get("total_ms", -1)), 0)
	assert_true(best.get("splits_ms", null) is Array)


func test_v8_migrates_to_v9_equipment() -> void:
	var v8 := {
		"save_version": 8,
		"gauntlet_best": {"total_ms": 0, "splits_ms": [], "trace": []},
	}
	var migrated := SaveMigration.migrate(v8, 9)
	assert_eq(int(migrated.get("save_version", 0)), 9)
	assert_true(migrated.has("equipment_owned"))
	assert_true(migrated.has("equipment_equipped"))
	assert_true(migrated.has("daily_missions"))
	assert_true(migrated.has("mission_lifetime"))
