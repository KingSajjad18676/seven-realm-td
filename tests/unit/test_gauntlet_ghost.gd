extends GutTest


func test_format_time_ms() -> void:
	assert_eq(GauntletGhostController.format_time_ms(0), "00:00.000")
	assert_eq(GauntletGhostController.format_time_ms(61001), "01:01.001")


func test_delta_vs_pb() -> void:
	var pb := {"total_ms": 100000}
	assert_eq(GauntletGhostController.delta_vs_pb(95000, pb), -5000)
	assert_eq(GauntletGhostController.delta_vs_pb(105000, pb), 5000)
	assert_eq(GauntletGhostController.delta_vs_pb(50000, {}), 0)


func test_ghost_labour_progress() -> void:
	var pb := {"splits_ms": [60000, 120000, 180000]}
	assert_almost_eq(GauntletGhostController.ghost_labour_progress(30000, pb), 0.5, 0.01)
	assert_almost_eq(GauntletGhostController.ghost_labour_progress(90000, pb), 1.5, 0.01)
