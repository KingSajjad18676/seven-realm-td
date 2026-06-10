extends GutTest


func test_scale_final_boss_data_boosts_hp_and_armor() -> void:
	var spawner := EnemySpawner.new()
	var ctx := BattleContext.new()
	var level := LevelData.new()
	level.level_id = "level_03"
	ctx.level_data = level
	ctx.runtime_modifiers = {"enemy_hp_mult": 1.59}
	spawner.context = ctx
	var data := EnemyData.new()
	data.enemy_id = "enemy_azhdaha"
	data.is_boss = true
	data.max_hp = 900.0
	data.armor = 8.0
	var scaled: EnemyData = spawner._scale_final_boss_data(data)
	var hp_mult := ContentCatalog.final_boss_hp_mult("level_03")
	assert_almost_eq(scaled.max_hp, 900.0 * hp_mult / 1.59, 0.01)
	assert_almost_eq(scaled.max_hp * 1.59, 900.0 * hp_mult, 0.01)
	assert_gt(scaled.armor, 8.0)
