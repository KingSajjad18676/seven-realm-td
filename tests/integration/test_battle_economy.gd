extends GutTest

var _ctx: BattleContext = null
var _economy: BattleEconomy = null


func before_each() -> void:
	_ctx = BattleTestFixtures.context_with_level(self, 50, 3)
	_economy = BattleTestFixtures.attach_economy(self, _ctx)


func test_spend_gold_fails_when_insufficient() -> void:
	assert_false(_economy.spend_gold(100))
	assert_eq(_economy.gold, 50)


func test_spend_gold_succeeds_when_affordable() -> void:
	assert_true(_economy.spend_gold(20))
	assert_eq(_economy.gold, 30)


func test_sacred_fire_spend() -> void:
	assert_true(_economy.spend_sacred_fire(2))
	assert_eq(_economy.sacred_fire, 1)
	assert_false(_economy.spend_sacred_fire(5))


func test_kill_rewards_add_gold_sf_and_materials() -> void:
	var enemy := BattleTestFixtures.make_enemy(
		"enemy_test", [], false, 15, 2, "iron_test", 3
	)
	_economy.apply_kill_rewards(enemy)
	assert_eq(_economy.gold, 65)
	assert_eq(_economy.sacred_fire, 5)
	assert_eq(int(_economy.forge_materials_earned.get("iron_test", 0)), 3)
