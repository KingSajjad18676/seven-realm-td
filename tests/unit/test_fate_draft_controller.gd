extends GutTest


func test_show_draft_builds_content_without_duplicates() -> void:
	var ctx := BattleTestFixtures.context_with_level(self)
	var state := BattleStateController.new()
	add_child(state)
	state.initialize(ctx)
	ctx.state_controller = state
	var panel := Panel.new()
	var content := VBoxContainer.new()
	content.name = "ContentRoot"
	panel.add_child(content)
	add_child(panel)
	var draft := FateDraftController.new()
	add_child(draft)
	draft.initialize(ctx, panel)
	draft.show_draft()
	assert_eq(panel.get_child_count(), 1, "Panel should only contain ContentRoot")
	assert_gt(content.get_child_count(), 0, "ContentRoot should be populated")
	var card_row := content.get_node_or_null("CardRow") as HBoxContainer
	assert_not_null(card_row)
	assert_gte(card_row.get_child_count(), 1, "Should offer at least one Fate card")
	var phase_two := content.get_node_or_null("PhaseTwo") as VBoxContainer
	assert_not_null(phase_two)
	assert_false(phase_two.visible, "Phase two should stay hidden until a card is picked")


func test_card_pick_shows_phase_two_in_campaign() -> void:
	var ctx := BattleTestFixtures.context_with_level(self)
	ctx.tutorial_active = false
	var state := BattleStateController.new()
	add_child(state)
	state.initialize(ctx)
	ctx.state_controller = state
	var panel := Panel.new()
	var content := VBoxContainer.new()
	content.name = "ContentRoot"
	panel.add_child(content)
	add_child(panel)
	var draft := FateDraftController.new()
	add_child(draft)
	draft.initialize(ctx, panel)
	draft.show_draft()
	var cards := ContentRegistry.get_all_fate_cards()
	assert_gt(cards.size(), 0)
	draft._on_card_picked(cards[0])
	var phase_two := content.get_node_or_null("PhaseTwo") as VBoxContainer
	assert_not_null(phase_two)
	assert_true(phase_two.visible, "Campaign pick should reveal objective and Continue")
	assert_true(panel.visible, "Panel should stay open until Continue in campaign")


func test_card_pick_finishes_draft_during_tutorial() -> void:
	var ctx := BattleTestFixtures.context_with_level(self)
	ctx.tutorial_active = true
	var state := BattleStateController.new()
	add_child(state)
	state.initialize(ctx)
	ctx.state_controller = state
	state.pause_battle()
	var panel := Panel.new()
	var content := VBoxContainer.new()
	content.name = "ContentRoot"
	panel.add_child(content)
	add_child(panel)
	var draft := FateDraftController.new()
	add_child(draft)
	draft.initialize(ctx, panel)
	draft.show_draft()
	var cards := ContentRegistry.get_all_fate_cards()
	draft._on_card_picked(cards[0])
	assert_false(panel.visible, "Tutorial should auto-close Pardeh after card pick")
