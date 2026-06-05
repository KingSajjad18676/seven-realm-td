extends GutTest


func test_collect_and_clear_unbanked() -> void:
	var economy := BattleEconomy.new()
	economy.collect_material("iron_falcon", 2)
	economy.collect_material("iron_falcon", 1)
	assert_eq(int(economy.get_unbanked_materials().get("iron_falcon", 0)), 3)
	economy.clear_unbanked_materials()
	assert_true(economy.get_unbanked_materials().is_empty())


func test_kill_rewards_no_longer_auto_credit_materials() -> void:
	var economy := BattleEconomy.new()
	var enemy := EnemyData.new()
	enemy.gold_reward = 5
	enemy.forge_material_id = "iron_falcon"
	enemy.forge_material_drop = 2
	economy.apply_kill_rewards(enemy)
	assert_eq(economy.gold, 5)
	assert_true(economy.get_unbanked_materials().is_empty())
