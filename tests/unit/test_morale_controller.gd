extends GutTest

var _ctx: BattleContext = null
var _morale: MoraleController = null


func before_each() -> void:
	_ctx = BattleTestFixtures.minimal_context(self)
	_morale = BattleTestFixtures.attach_morale(self, _ctx)


func test_clamps_between_zero_and_max() -> void:
	_morale.add(200)
	assert_eq(_morale.current, MoraleController.MAX_MORALE)
	_morale.add(-500)
	assert_eq(_morale.current, 0)


func test_morale_mult_at_fifty() -> void:
	_morale.current = 50
	_morale._sync_modifiers()
	assert_almost_eq(MoraleController.get_damage_mult(_ctx), 1.1, 0.001)


func test_morale_mult_at_hundred() -> void:
	_morale.current = 100
	_morale._sync_modifiers()
	assert_almost_eq(MoraleController.get_damage_mult(_ctx), 1.2, 0.001)


func test_rate_penalty_below_twenty_five() -> void:
	_morale.current = 20
	_morale._sync_modifiers()
	assert_true(_ctx.runtime_modifiers.has("morale_rate_penalty"))
	assert_almost_eq(MoraleController.get_rate_mult(_ctx), 1.04 * 0.85, 0.01)


func test_no_rate_penalty_at_twenty_five_or_above() -> void:
	_morale.current = 25
	_morale._sync_modifiers()
	assert_false(_ctx.runtime_modifiers.has("morale_rate_penalty"))
