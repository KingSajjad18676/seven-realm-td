extends GutTest

var _ctx: BattleContext = null
var _mods: RunModifierService = null


func before_each() -> void:
	_ctx = BattleTestFixtures.context_with_level(self, 0, 0)
	_ctx.economy = BattleEconomy.new()
	add_child(_ctx.economy)
	_ctx.economy.initialize(_ctx)
	_mods = BattleTestFixtures.attach_run_modifiers(self, _ctx)


func test_relic_attack_mult_stacks() -> void:
	var relic_a := RelicData.new()
	relic_a.relic_id = "relic_a"
	relic_a.attack_mult = 1.1
	var relic_b := RelicData.new()
	relic_b.relic_id = "relic_b"
	relic_b.attack_mult = 1.2
	_mods.add_relic(relic_a)
	_mods.add_relic(relic_b)
	assert_almost_eq(float(_ctx.runtime_modifiers.get("attack_mult", 1.0)), 1.32, 0.001)


func test_wave_gold_bonus_on_wave_started() -> void:
	var relic := RelicData.new()
	relic.relic_id = "relic_gold"
	relic.gold_bonus_per_wave = 7
	_mods.add_relic(relic)
	_mods.on_wave_started()
	assert_eq(_ctx.economy.gold, 7)


func test_wave_gold_penalty_modifier() -> void:
	_ctx.runtime_modifiers["wave_gold_penalty"] = -5
	_mods.on_wave_started()
	assert_eq(_ctx.economy.gold, -5)
