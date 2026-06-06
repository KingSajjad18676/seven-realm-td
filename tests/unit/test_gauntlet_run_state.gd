extends GutTest


func test_level_sequence() -> void:
	var run := GauntletRunState.new()
	run.start_run(["tower_archer", "tower_heavy", "tower_control"])
	assert_eq(run.current_level_id(), "level_01")
	run.advance_labour()
	assert_eq(run.current_level_id(), "level_02")
	assert_eq(GauntletRunState.GAUNTLET_LEVEL_IDS.size(), 7)


func test_split_and_trace() -> void:
	var run := GauntletRunState.new()
	run.start_run(["tower_archer", "tower_heavy", "tower_control"])
	run.record_labour_clear(120000)
	run.record_trace_sample(5000, 2)
	assert_eq(run.splits_ms.size(), 1)
	assert_eq(int(run.splits_ms[0]), 120000)
	assert_eq(run.trace.size(), 1)
	assert_eq(int(run.trace[0].get("wave", -1)), 2)


func test_serialization_roundtrip() -> void:
	var run := GauntletRunState.new()
	run.start_run(["tower_archer", "tower_sacred_fire", "tower_control"])
	run.labour_index = 2
	run.record_labour_clear(90000)
	run.record_trace_sample(45000, 5)
	var restored := GauntletRunState.from_dict(run.to_dict())
	assert_eq(restored.labour_index, 2)
	assert_eq(restored.run_tower_ids.size(), 3)
	assert_eq(restored.splits_ms.size(), 1)
	assert_eq(restored.trace.size(), 1)


func test_build_launch() -> void:
	var run := GauntletRunState.new()
	run.start_run(["tower_archer", "tower_heavy", "tower_control"])
	var launch := run.build_launch()
	assert_true(launch.is_gauntlet_mode)
	assert_eq(launch.level_id, "level_01")
	assert_eq(launch.run_tower_ids.size(), 3)
	assert_false(launch.is_campaign_mode())
