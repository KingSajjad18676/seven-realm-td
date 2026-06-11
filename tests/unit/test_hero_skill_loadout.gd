extends GutTest


func test_default_skill_is_rostam_charge() -> void:
	if SaveSystem == null:
		pending("SaveSystem autoload missing")
		return
	assert_eq(SaveSystem.get_hero_skill_selected(), "rostam_charge")


func test_rostam_charge_always_unlocked() -> void:
	if SaveSystem == null:
		pending("SaveSystem autoload missing")
		return
	assert_true(SaveSystem.is_hero_skill_unlocked("rostam_charge"))


func test_hero_manager_applies_selected_skill() -> void:
	var manager := HeroManager.new()
	var ctx := BattleContext.new()
	var level := LevelData.new()
	level.level_id = "level_01"
	level.hero_id = "rostam"
	ctx.level_data = level
	ctx.runtime_modifiers = {}
	if SaveSystem:
		SaveSystem.set_hero_skill_selected("rostam_charge")
	manager.initialize(ctx, Node2D.new())
	assert_not_null(manager.hero)
	assert_eq(manager.hero.data.skill_id, "rostam_charge")


func test_gordafarid_volley_in_catalog() -> void:
	assert_true(ContentCatalog.is_valid_hero_skill_id("gordafarid_volley"))


func test_esfandiyar_bulwark_in_catalog() -> void:
	assert_true(ContentCatalog.is_valid_hero_skill_id("esfandiyar_bulwark"))


func test_new_heroes_in_catalog() -> void:
	var ids: Array[String] = []
	for hero in ContentCatalog.build_heroes():
		ids.append(hero.hero_id)
	assert_true("gordafarid" in ids)
	assert_true("esfandiyar" in ids)
