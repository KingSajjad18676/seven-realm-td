extends GutTest


func _wave_manager_with_waves(wave_count: int) -> WaveManager:
	var wm := WaveManager.new()
	var level := LevelData.new()
	level.level_id = "level_01"
	for i in wave_count:
		level.waves.append(WaveData.new())
	wm.context = BattleContext.new()
	wm.context.level_data = level
	wm.total_waves = wave_count
	return wm


func test_pardeh_after_every_fifth_wave() -> void:
	var wm := _wave_manager_with_waves(30)
	for idx in [4, 9, 14, 19, 24]:
		wm.current_wave_index = idx
		assert_true(wm._should_offer_pardeh(), "Pardeh expected after wave %d" % (idx + 1))


func test_no_pardeh_after_final_boss_wave() -> void:
	var wm := _wave_manager_with_waves(30)
	wm.current_wave_index = 29
	assert_false(wm._should_offer_pardeh(), "No Pardeh after final boss wave")


func test_no_pardeh_on_non_fifth_waves() -> void:
	var wm := _wave_manager_with_waves(30)
	for idx in [0, 1, 2, 5, 11]:
		wm.current_wave_index = idx
		assert_false(wm._should_offer_pardeh(), "No Pardeh after wave %d" % (idx + 1))


func test_no_pardeh_in_horde_or_endless() -> void:
	var wm := _wave_manager_with_waves(15)
	wm.current_wave_index = 4
	wm.enable_horde_mode()
	assert_false(wm._should_offer_pardeh())
	wm._horde_mode = false
	wm.enable_endless_mode()
	assert_false(wm._should_offer_pardeh())
