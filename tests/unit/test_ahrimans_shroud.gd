extends GutTest


func test_reveal_cost_by_node_type() -> void:
	var run := CampaignRunState.new()
	assert_eq(run.get_reveal_cost({"type": CampaignRunState.NODE_SKIRMISH}), 1)
	assert_eq(run.get_reveal_cost({"type": CampaignRunState.NODE_ANVIL}), 1)
	assert_eq(run.get_reveal_cost({"type": CampaignRunState.NODE_SHRINE}), 1)
	assert_eq(run.get_reveal_cost({"type": CampaignRunState.NODE_LABOUR_BOSS}), 2)
	assert_eq(run.get_reveal_cost({"type": CampaignRunState.NODE_THRONE_KAVUS}), 2)
	assert_eq(run.get_reveal_cost({"type": CampaignRunState.NODE_FINALE}), 3)


func test_enable_shroud_sets_starting_sf() -> void:
	var run := CampaignRunState.new()
	run.enable_ahrimans_shroud()
	assert_true(run.is_shroud_active())
	assert_eq(run.run_sacred_fire, 5)


func test_reveal_node_spends_sf() -> void:
	var run := CampaignRunState.new()
	run.generate_run()
	run.enable_ahrimans_shroud()
	run.mark_node_cleared(run.current_node_id)
	var reachable := run.get_reachable_node_ids()
	assert_gt(reachable.size(), 0)
	var target_id := reachable[0]
	var node := run.get_node(target_id)
	var cost := run.get_reveal_cost(node)
	var before := run.run_sacred_fire
	assert_true(run.reveal_node(target_id))
	assert_eq(run.run_sacred_fire, before - cost)
	assert_true(run.is_node_revealed(target_id))


func test_reveal_blocks_when_insufficient_sf() -> void:
	var run := CampaignRunState.new()
	run.generate_run()
	run.enable_ahrimans_shroud()
	run.run_sacred_fire = 0
	run.mark_node_cleared(run.current_node_id)
	var reachable := run.get_reachable_node_ids()
	assert_gt(reachable.size(), 0)
	assert_false(run.reveal_node(reachable[0]))


func test_current_node_counts_as_revealed() -> void:
	var run := CampaignRunState.new()
	run.generate_run()
	run.enable_ahrimans_shroud()
	assert_true(run.is_node_revealed(run.current_node_id))


func test_from_dict_defaults_old_saves() -> void:
	var run := CampaignRunState.from_dict({
		"seed": 99,
		"nodes": [],
		"current_node_id": "",
	})
	assert_false(run.is_shroud_active())
	assert_eq(run.run_sacred_fire, 0)
	assert_eq(run.revealed_node_ids.size(), 0)


func test_launch_data_carries_run_sf() -> void:
	var launch := BattleLaunchData.new()
	launch.ahrimans_shroud_enabled = true
	launch.run_sacred_fire = 4
	var copy := launch.duplicate_launch()
	assert_true(copy.ahrimans_shroud_enabled)
	assert_eq(copy.run_sacred_fire, 4)


func test_shroud_fields_roundtrip_dict() -> void:
	var run := CampaignRunState.new()
	run.enable_ahrimans_shroud()
	run.revealed_node_ids.append("act1_anvil")
	run.run_sacred_fire = 3
	var restored := CampaignRunState.from_dict(run.to_dict())
	assert_true(restored.is_shroud_active())
	assert_eq(restored.run_sacred_fire, 3)
	assert_has(restored.revealed_node_ids, "act1_anvil")


func test_sync_sacred_fire_from_battle() -> void:
	var run := CampaignRunState.new()
	run.enable_ahrimans_shroud()
	run.sync_sacred_fire_from_battle(2)
	assert_eq(run.run_sacred_fire, 2)
	run.sync_sacred_fire_from_battle(-1)
	assert_eq(run.run_sacred_fire, 0)
