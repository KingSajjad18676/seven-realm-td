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
