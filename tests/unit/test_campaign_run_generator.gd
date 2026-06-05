extends GutTest


func test_generator_finale_points_to_damavand() -> void:
	var nodes := CampaignRunGenerator.generate(12345)
	var finale := {}
	for n in nodes:
		if str(n.get("type", "")) == CampaignRunState.NODE_FINALE:
			finale = n
			break
	assert_false(finale.is_empty())
	assert_eq(str(finale.get("level_id", "")), "level_08_damavand")


func test_campaign_run_state_reachable_includes_current_battle_node() -> void:
	var run := CampaignRunState.new()
	run.generate_run()
	var reachable := run.get_reachable_node_ids()
	assert_has(reachable, run.current_node_id)
