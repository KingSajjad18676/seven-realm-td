extends GutTest


func test_get_tower_flame_archer() -> void:
	var tower := ContentRegistry.get_tower("tower_flame_archer")
	assert_not_null(tower)
	assert_eq(tower.tower_id, "tower_flame_archer")


func test_get_enemy_lion_boss() -> void:
	var enemy := ContentRegistry.get_enemy("enemy_lion_boss")
	assert_not_null(enemy)
	assert_true(enemy.is_boss)


func test_get_level_01_has_five_waves() -> void:
	var level := ContentRegistry.get_level("level_01")
	assert_not_null(level)
	assert_eq(level.waves.size(), 5)


func test_fate_cards_available() -> void:
	var cards := ContentRegistry.get_all_fate_cards()
	assert_gte(cards.size(), 8)
