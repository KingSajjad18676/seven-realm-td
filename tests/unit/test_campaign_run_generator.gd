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


func test_generator_can_spawn_throne_of_kavus() -> void:
	var found := false
	for seed in range(1, 500):
		var nodes := CampaignRunGenerator.generate(seed)
		for n in nodes:
			if str(n.get("type", "")) == CampaignRunState.NODE_THRONE_KAVUS:
				found = true
				break
		if found:
			break
	assert_true(found, "Expected at least one Throne of Kavus node in sampled seeds")


func test_campaign_run_state_persists_pending_kavus_folly() -> void:
	var run := CampaignRunState.new()
	run.pending_kavus_folly = true
	var restored := CampaignRunState.from_dict(run.to_dict())
	assert_true(restored.pending_kavus_folly)


func test_campaign_run_state_reachable_includes_current_battle_node() -> void:
	var run := CampaignRunState.new()
	run.generate_run()
	var reachable := run.get_reachable_node_ids()
	assert_has(reachable, run.current_node_id)
