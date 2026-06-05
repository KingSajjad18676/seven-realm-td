extends GutTest

class StubStateController extends BattleStateController:
	var stub_active_count: int = 0

	func get_active_enemy_count() -> int:
		return stub_active_count


var _ctx: BattleContext = null
var _wave_manager: WaveManager = null
var _stub_state: StubStateController = null


func before_each() -> void:
	_ctx = BattleTestFixtures.minimal_context(self)
	_stub_state = StubStateController.new()
	add_child(_stub_state)
	_stub_state.initialize(_ctx)
	_stub_state.current_state = GameEnums.BattleState.WAVE_ACTIVE
	_ctx.state_controller = _stub_state
	_wave_manager = WaveManager.new()
	add_child(_wave_manager)
	_wave_manager.initialize(_ctx)


func test_waits_until_enemies_cleared() -> void:
	_stub_state.stub_active_count = 1
	var wait_task := _wave_manager._wait_for_wave_clear()
	await wait_frames(2)
	assert_true(is_instance_valid(_wave_manager))
	_stub_state.stub_active_count = 0
	await wait_task


func test_exits_early_on_defeat() -> void:
	_stub_state.stub_active_count = 5
	_stub_state.current_state = GameEnums.BattleState.DEFEAT
	await _wave_manager._wait_for_wave_clear()


func test_exits_early_on_victory() -> void:
	_stub_state.stub_active_count = 3
	_stub_state.current_state = GameEnums.BattleState.VICTORY
	await _wave_manager._wait_for_wave_clear()
