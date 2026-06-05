class_name FateDraftController
extends Node

const REROLL_SF_COST := 1

var context: BattleContext = null
var _panel: Control = null
var _reroll_used: bool = false
var _objective_accepted: bool = false
var _strategic_used: bool = false


func initialize(ctx: BattleContext, panel: Control) -> void:
	context = ctx
	_panel = panel
	if _panel:
		_panel.visible = false


func show_draft() -> void:
	if _panel == null or context == null:
		return
	_reroll_used = false
	_objective_accepted = false
	_strategic_used = false
	_panel.visible = true
	if context.state_controller:
		context.state_controller.pause_battle()
	var level_id := context.level_data.level_id if context.level_data else ""
	AnalyticsService.pardeh_break_opened(level_id)
	_build_pardeh_ui()


func _build_pardeh_ui() -> void:
	for child in _panel.get_children():
		if child.name != "SkipButton":
			child.queue_free()
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel.add_child(vbox)
	var title := Label.new()
	title.text = "Pardeh Break — Weave your Fate"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	var card_row := HBoxContainer.new()
	card_row.name = "CardRow"
	card_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(card_row)
	_populate_cards(card_row)
	var obj_row := HBoxContainer.new()
	obj_row.alignment = BoxContainer.ALIGNMENT_CENTER
	var obj := ContentRegistry.get_random_objective() if ContentRegistry else null
	if obj:
		var accept_obj := Button.new()
		accept_obj.text = "Accept: %s" % obj.title
		accept_obj.pressed.connect(_on_accept_objective.bind(obj))
		obj_row.add_child(accept_obj)
		var decline_obj := Button.new()
		decline_obj.text = "Decline objective"
		decline_obj.pressed.connect(func() -> void: _objective_accepted = true)
		obj_row.add_child(decline_obj)
	vbox.add_child(obj_row)
	var strat_row := HBoxContainer.new()
	strat_row.alignment = BoxContainer.ALIGNMENT_CENTER
	for action in ["Repair +15 region light", "Gold surge +20", "Morale +10"]:
		var btn := Button.new()
		btn.text = action
		btn.pressed.connect(_on_strategic.bind(action))
		strat_row.add_child(btn)
	vbox.add_child(strat_row)
	var reroll_btn := Button.new()
	reroll_btn.text = "Reroll cards (%d SF)" % REROLL_SF_COST
	reroll_btn.pressed.connect(_on_reroll.bind(card_row))
	vbox.add_child(reroll_btn)
	var continue_btn := Button.new()
	continue_btn.text = "Continue"
	continue_btn.pressed.connect(_close)
	vbox.add_child(continue_btn)
	var skip := _panel.get_node_or_null("SkipButton") as Button
	if skip:
		skip.visible = false


func _populate_cards(container: HBoxContainer) -> void:
	for child in container.get_children():
		child.queue_free()
	var pool := ContentRegistry.get_all_fate_cards()
	pool.shuffle()
	var picks: Array[FateCardData] = []
	for i in mini(3, pool.size()):
		picks.append(pool[i])
	for card in picks:
		var btn := Button.new()
		btn.text = "%s\n%s" % [card.title, card.description]
		btn.custom_minimum_size = Vector2(200, 100)
		btn.pressed.connect(_on_card_picked.bind(card))
		container.add_child(btn)


func _on_reroll(card_row: HBoxContainer) -> void:
	if _reroll_used or context == null or context.economy == null:
		return
	if not context.economy.spend_sacred_fire(REROLL_SF_COST):
		if context.bridge:
			context.bridge.alert_message.emit("Need Sacred Fire to reroll", 40)
		return
	_reroll_used = true
	_populate_cards(card_row)


func _on_accept_objective(obj: ObjectiveData) -> void:
	_objective_accepted = true
	if context and context.objectives:
		context.objectives.assign_objective(obj)


func _on_strategic(action: String) -> void:
	if _strategic_used or context == null:
		return
	_strategic_used = true
	match action:
		"Repair +15 region light":
			if context.map_light:
				for rid in context.map_light.region_light.keys():
					context.map_light.repair_region_light(rid, 15)
		"Gold surge +20":
			if context.economy:
				context.economy.add_gold(20)
		"Morale +10":
			if context.morale:
				context.morale.add(10)
	if context.bridge:
		context.bridge.alert_message.emit(action, 30)


func _on_card_picked(card: FateCardData) -> void:
	if context == null:
		return
	context.selected_fate_card = card
	if card.boon_gold_bonus > 0 and context.economy:
		context.economy.add_gold(card.boon_gold_bonus)
	if card.boon_sacred_fire_bonus > 0 and context.economy:
		context.economy.add_sacred_fire(card.boon_sacred_fire_bonus)
	if card.boon_attack_mult != 1.0:
		context.runtime_modifiers["attack_mult"] = card.boon_attack_mult
	if card.curse_enemy_hp_mult != 1.0:
		context.runtime_modifiers["enemy_hp_mult"] = card.curse_enemy_hp_mult
	if card.curse_corruption_rate > 0.0:
		context.runtime_modifiers["corruption_rate_bonus"] = card.curse_corruption_rate
	AnalyticsService.fate_card_selected(card.card_id)
	CombatEvents.fate_card_selected.emit(card.card_id)
	if context.bridge:
		context.bridge.alert_message.emit("Fate chosen: %s" % card.title, 20)


func _close() -> void:
	if _panel:
		_panel.visible = false
		for child in _panel.get_children():
			if child.name != "SkipButton":
				child.queue_free()
		var skip := _panel.get_node_or_null("SkipButton") as Button
		if skip:
			skip.visible = true
	if context and context.state_controller:
		context.state_controller.resume_battle()
