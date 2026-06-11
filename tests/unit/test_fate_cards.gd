extends GutTest


func test_fate_card_count_is_sixteen() -> void:
	var cards := ContentCatalog.build_fate_cards()
	assert_eq(cards.size(), 16)


func test_fate_card_ids_unique() -> void:
	var seen: Dictionary = {}
	for card in ContentCatalog.build_fate_cards():
		assert_false(seen.has(card.card_id), "duplicate %s" % card.card_id)
		seen[card.card_id] = true


func test_new_fate_cards_present() -> void:
	var expected := [
		"card_sacred_aegis",
		"card_corruption_embrace",
		"card_merchant_caravan",
		"card_divine_wind",
		"card_binders_oath",
		"card_farr_echo",
		"card_gate_warden",
		"card_shahnameh_thread",
	]
	var ids: Array[String] = []
	for card in ContentCatalog.build_fate_cards():
		ids.append(card.card_id)
	for card_id in expected:
		assert_true(card_id in ids, card_id)


func test_merchant_caravan_applies_enemy_count_mult() -> void:
	var ctx := BattleContext.new()
	ctx.runtime_modifiers = {}
	ctx.economy = BattleEconomy.new()
	ctx.economy.initialize(ctx)
	var card := FateCardData.new()
	card.card_id = "card_merchant_caravan"
	var draft := FateDraftController.new()
	draft.initialize(ctx, null)
	draft._apply_fate_effects(card)
	assert_eq(int(ctx.runtime_modifiers.get("enemy_count_mult", 1.0) * 10), 11)
