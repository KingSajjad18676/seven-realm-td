extends GutTest

var _ctx: BattleContext = null
var _objectives: ObjectiveController = null


func before_each() -> void:
	_ctx = BattleTestFixtures.minimal_context(self)
	_objectives = BattleTestFixtures.attach_objectives(self, _ctx)


func test_no_leaks_fails_on_gate_leak() -> void:
	_objectives.assign_objective(BattleTestFixtures.make_objective("no_leaks"))
	_objectives.on_gate_leak()
	_objectives.evaluate_at_victory()
	assert_true(_objectives.failed)
	assert_false(_objectives.completed)


func test_no_leaks_completes_with_zero_leaks() -> void:
	_objectives.assign_objective(BattleTestFixtures.make_objective("no_leaks"))
	_objectives.evaluate_at_victory()
	assert_true(_objectives.completed)
	assert_false(_objectives.failed)


func test_no_hijack_fails_on_hijack() -> void:
	_objectives.assign_objective(BattleTestFixtures.make_objective("no_hijack"))
	_objectives.on_hijack()
	_objectives.evaluate_at_victory()
	assert_true(_objectives.failed)
	assert_false(_objectives.completed)


func test_no_hijack_completes_without_hijack() -> void:
	_objectives.assign_objective(BattleTestFixtures.make_objective("no_hijack"))
	_objectives.evaluate_at_victory()
	assert_true(_objectives.completed)


func test_cleanse_twice_tracks_progress() -> void:
	var obj := BattleTestFixtures.make_objective("cleanse_twice", 2)
	_objectives.assign_objective(obj)
	_objectives.on_cleanse()
	assert_eq(_objectives.progress, 1)
	assert_false(_objectives.completed)
	_objectives.on_cleanse()
	assert_true(_objectives.completed)


func test_cleanse_twice_evaluates_at_victory() -> void:
	var obj := BattleTestFixtures.make_objective("cleanse_twice", 2)
	_objectives.assign_objective(obj)
	_objectives.on_cleanse()
	_objectives.on_cleanse()
	_objectives.evaluate_at_victory()
	assert_true(_objectives.completed)


func test_vow_breaks_on_forbidden_action() -> void:
	BattleTestFixtures.attach_morale(self, _ctx)
	var vow := BattleTestFixtures.make_vow("vow_no_hero_move", 6)
	_objectives.activate_vow(vow, 1, 10)
	var morale_before := _ctx.morale.current
	CombatEvents.hero_moved.emit()
	assert_false(_objectives.is_vow_active())
	assert_eq(_ctx.morale.current, morale_before - 6)


func test_vow_honored_when_block_cleared() -> void:
	BattleTestFixtures.attach_economy(self, _ctx)
	BattleTestFixtures.attach_morale(self, _ctx)
	var vow := BattleTestFixtures.make_vow("vow_no_upgrade", 5)
	_objectives.activate_vow(vow, 1, 3)
	_objectives._current_wave = 3
	_objectives.on_wave_cleared()
	assert_eq(_objectives.vows_honored, 1)
	assert_false(_objectives.is_vow_active())
	assert_eq(_ctx.economy.sacred_fire, 2)
