extends GutTest


func test_migrate_v6_campaign_run_relic_ids_to_slots() -> void:
	var data := {
		"save_version": 6,
		"campaign_run": {
			"relic_ids": ["relic_cup_of_jamshid", "card_derafsh_oath"],
		},
	}
	var migrated := SaveMigration.migrate(data, 7)
	assert_eq(int(migrated.get("save_version", 0)), 7)
	var run: Dictionary = migrated["campaign_run"]
	assert_false(run.has("relic_ids"))
	assert_eq(run["tower_relic_slots"].get("tower_archer"), "relic_cup_of_jamshid")


func test_apply_slot_overwrites_existing() -> void:
	var slots := {"tower_archer": "relic_cup_of_jamshid"}
	var updated := RelicSlotHelper.apply_slot(slots, "tower_archer", "relic_derafsh_fragment")
	assert_eq(updated.get("tower_archer"), "relic_derafsh_fragment")
