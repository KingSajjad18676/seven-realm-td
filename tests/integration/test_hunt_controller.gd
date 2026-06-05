extends GutTest

var _ctx: BattleContext = null
var _hunt: HuntController = null


func before_each() -> void:
	_ctx = BattleTestFixtures.minimal_context(self)
	_hunt = BattleTestFixtures.attach_hunt(self, _ctx)


func test_corruptor_grants_one_shard() -> void:
	var enemy := BattleTestFixtures.make_enemy("enemy_corruptor", ["corruptor"])
	_hunt.on_enemy_slain(enemy)
	assert_eq(_hunt.binding_shards, 1)
	assert_almost_eq(float(_ctx.runtime_modifiers.get("hunt_binding_bonus", 0.0)), 0.35, 0.001)


func test_boss_grants_two_shards() -> void:
	var enemy := BattleTestFixtures.make_enemy("enemy_boss", [], true)
	_hunt.on_enemy_slain(enemy)
	assert_eq(_hunt.binding_shards, 2)


func test_serpent_guard_grants_one_shard() -> void:
	var enemy := BattleTestFixtures.make_enemy("enemy_zahhak_serpent_guard")
	_hunt.on_enemy_slain(enemy)
	assert_eq(_hunt.binding_shards, 1)


func test_shards_cap_at_three() -> void:
	for i in 5:
		var enemy := BattleTestFixtures.make_enemy("enemy_corruptor_%d" % i, ["corruptor"])
		_hunt.on_enemy_slain(enemy)
	assert_eq(_hunt.binding_shards, HuntController.SHARDS_TO_BIND)
	assert_eq(_hunt.milestones_reached, HuntController.SHARDS_TO_BIND)


func test_non_qualifying_enemy_grants_nothing() -> void:
	var enemy := BattleTestFixtures.make_enemy("enemy_jackal")
	_hunt.on_enemy_slain(enemy)
	assert_eq(_hunt.binding_shards, 0)
