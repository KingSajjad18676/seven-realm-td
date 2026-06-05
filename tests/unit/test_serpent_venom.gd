extends GutTest


func test_venom_stacks_increase_damage_taken() -> void:
	var enemy := EnemyController.new()
	var data := EnemyData.new()
	data.max_hp = 100.0
	data.enemy_id = "enemy_jackal"
	enemy.data = data
	enemy.current_hp = 100.0
	enemy.apply_venom(2, 4.0, 3.0)
	assert_eq(enemy._venom_stacks, 2)
	assert_gt(enemy._damage_taken_mult, 1.0)


func test_venom_kill_tracks_source() -> void:
	var ctx := BattleContext.new()
	var tower_data := TowerData.new()
	tower_data.tower_id = "tower_zahhak_serpent"
	tower_data.attack_behavior = GameEnums.AttackBehavior.TWIN
	var tower := TowerController.new()
	tower.context = ctx
	tower.data = tower_data
	var enemy := EnemyController.new()
	var data := EnemyData.new()
	data.max_hp = 50.0
	enemy.data = data
	enemy.context = ctx
	enemy.apply_venom(1, 5.0, 2.0, tower)
	assert_true(enemy.has_venom())
	tower.on_venom_kill()
	assert_eq(tower._hunger_stacks, 1)


func test_decoy_flag() -> void:
	var enemy := EnemyController.new()
	var data := EnemyData.new()
	data.gold_reward = 10
	enemy.data = data
	enemy.set_decoy(true)
	assert_true(enemy.is_decoy())
	assert_eq(enemy.data.gold_reward, 1)
