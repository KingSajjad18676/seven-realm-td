extends GutTest


func test_generate_run_has_five_nodes() -> void:
	var run := RogueliteRunState.new()
	run.generate_run()
	assert_eq(run.nodes.size(), 5)
	assert_eq(run.current_index, 0)
	assert_true(run.tower_relic_slots.is_empty())


func test_advance_stops_at_end() -> void:
	var run := RogueliteRunState.new()
	run.generate_run()
	assert_true(run.advance())
	assert_eq(run.current_index, 1)
	run.current_index = run.nodes.size() - 1
	assert_false(run.advance())
	assert_eq(run.current_index, run.nodes.size())


func test_get_current_node_empty_when_out_of_bounds() -> void:
	var run := RogueliteRunState.new()
	run.generate_run()
	run.current_index = 99
	assert_true(run.get_current_node().is_empty())


func test_to_dict_from_dict_roundtrip() -> void:
	var run := RogueliteRunState.new()
	run.generate_run()
	run.slot_relic("relic_cup_of_jamshid", "tower_archer")
	run.current_index = 2
	var restored := RogueliteRunState.from_dict(run.to_dict())
	assert_eq(restored.seed, run.seed)
	assert_eq(restored.current_index, 2)
	assert_eq(restored.nodes.size(), 5)
	assert_eq(restored.get_slotted_relic_id("tower_archer"), "relic_cup_of_jamshid")
