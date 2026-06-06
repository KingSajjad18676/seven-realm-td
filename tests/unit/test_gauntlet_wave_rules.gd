extends GutTest

var _wave_manager: WaveManager
var _context: BattleContext


func before_each() -> void:
	_context = BattleContext.new()
	_context.launch_data = BattleLaunchData.new()
	_context.launch_data.is_gauntlet_mode = true
	_context.runtime_modifiers = {}
	_wave_manager = WaveManager.new()
	add_child_autofree(_wave_manager)
	_wave_manager.initialize(_context)
	_wave_manager.current_wave_index = 0


func test_apply_gauntlet_pre_battle_rush_scales_wave() -> void:
	_context.runtime_modifiers["gauntlet_pre_battle_rush"] = true
	var wave := WaveData.new()
	wave.spawn_groups = [{"enemy_id": "enemy_jackal", "count": 4}]
	var scaled := _wave_manager._apply_gauntlet_wave_modifiers(wave)
	assert_eq(int(scaled.spawn_groups[0].get("count", 0)), 5)
	assert_false(_context.runtime_modifiers.has("gauntlet_pre_battle_rush"))


func test_apply_gauntlet_overwhelm_scales_wave() -> void:
	_context.runtime_modifiers["gauntlet_next_wave_overwhelm"] = 1.3
	var wave := WaveData.new()
	wave.spawn_groups = [{"enemy_id": "enemy_jackal", "count": 10}]
	var scaled := _wave_manager._apply_gauntlet_wave_modifiers(wave)
	assert_eq(int(scaled.spawn_groups[0].get("count", 0)), 13)


func test_pardeh_skipped_in_gauntlet() -> void:
	_wave_manager.current_wave_index = 4
	_wave_manager.total_waves = 30
	assert_false(_wave_manager._should_offer_pardeh())
