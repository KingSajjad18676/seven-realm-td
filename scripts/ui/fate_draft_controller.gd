class_name FateDraftController
extends Node

const REROLL_SF_COST := 1

var context: BattleContext = null
var _panel: Control = null
var _content_root: VBoxContainer = null
var _reroll_used: bool = false
var _objective_accepted: bool = false
var _strategic_used: bool = false
var _card_picked: bool = false
var _continue_btn: Button = null
var _card_row: HBoxContainer = null
var _phase_two_root: VBoxContainer = null


func initialize(ctx: BattleContext, panel: Control) -> void:
	context = ctx
	_panel = panel
	if _panel:
		_panel.visible = false
		_content_root = _panel.get_node_or_null("ContentRoot") as VBoxContainer


func show_draft() -> void:
	if _panel == null or context == null:
		return
	_reroll_used = false
	_objective_accepted = false
	_strategic_used = false
	_card_picked = false
	_continue_btn = null
	_card_row = null
	_phase_two_root = null
	_panel.visible = true
	if context.state_controller:
		context.state_controller.pause_battle()
	var level_id := context.level_data.level_id if context.level_data else ""
	AnalyticsService.pardeh_break_opened(level_id)
	_build_pardeh_ui()


func _clear_content_root() -> void:
	if _content_root == null:
		return
	for child in _content_root.get_children():
		_content_root.remove_child(child)
		child.queue_free()
	_content_root.add_theme_constant_override("separation", 10)


func _build_pardeh_ui() -> void:
	if _content_root == null:
		return
	_clear_content_root()
	var title := Label.new()
	title.text = "Pardeh Break - Weave your Fate"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	_content_root.add_child(title)
	var hint := Label.new()
	hint.text = "Choose a Fate card to continue"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_content_root.add_child(hint)
	if _can_retreat_to_forge():
		var early_retreat := Button.new()
		early_retreat.text = "Retreat to Forge (bank materials)"
		early_retreat.pressed.connect(_on_retreat_pressed)
		_content_root.add_child(early_retreat)
	_card_row = HBoxContainer.new()
	_card_row.name = "CardRow"
	_card_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_card_row.add_theme_constant_override("separation", 12)
	_content_root.add_child(_card_row)
	_populate_cards(_card_row)
	var reroll_btn := Button.new()
	reroll_btn.text = "Reroll cards (%d SF)" % REROLL_SF_COST
	reroll_btn.pressed.connect(_on_reroll)
	_content_root.add_child(reroll_btn)
	_phase_two_root = VBoxContainer.new()
	_phase_two_root.name = "PhaseTwo"
	_phase_two_root.visible = false
	_phase_two_root.add_theme_constant_override("separation", 8)
	_content_root.add_child(_phase_two_root)
	_build_phase_two(_phase_two_root)


func _build_phase_two(container: VBoxContainer) -> void:
	var obj_row := HBoxContainer.new()
	obj_row.alignment = BoxContainer.ALIGNMENT_CENTER
	obj_row.add_theme_constant_override("separation", 8)
	if ContentRegistry:
		var obj: ObjectiveData = ContentRegistry.get_random_objective()
		if obj:
			var accept_obj := Button.new()
			accept_obj.text = "Accept: %s" % obj.title
			accept_obj.pressed.connect(_on_accept_objective.bind(obj))
			obj_row.add_child(accept_obj)
			var decline_obj := Button.new()
			decline_obj.text = "Decline objective"
			decline_obj.pressed.connect(func() -> void: _objective_accepted = true)
			obj_row.add_child(decline_obj)
	container.add_child(obj_row)
	var strat_row := HBoxContainer.new()
	strat_row.alignment = BoxContainer.ALIGNMENT_CENTER
	strat_row.add_theme_constant_override("separation", 8)
	for action in ["Repair +15 region light", "Gold surge +20", "Morale +10"]:
		var btn := Button.new()
		btn.text = action
		btn.pressed.connect(_on_strategic.bind(action))
		strat_row.add_child(btn)
	container.add_child(strat_row)
	_continue_btn = Button.new()
	_continue_btn.text = "Continue"
	_continue_btn.disabled = true
	_continue_btn.pressed.connect(_on_continue_pressed)
	container.add_child(_continue_btn)
	if _can_retreat_to_forge():
		var retreat_btn := Button.new()
		retreat_btn.text = "Retreat to Forge (bank materials)"
		retreat_btn.pressed.connect(_on_retreat_pressed)
		container.add_child(retreat_btn)


func _populate_cards(container: HBoxContainer) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()
	var pool: Array[FateCardData] = ContentRegistry.get_all_fate_cards()
	var shuffled := pool.duplicate()
	shuffled.shuffle()
	var picks: Array[FateCardData] = []
	for i in range(mini(3, shuffled.size())):
		picks.append(shuffled[i])
	for card in picks:
		var btn := Button.new()
		btn.text = "%s\n%s" % [card.title, card.description]
		btn.custom_minimum_size = Vector2(220, 120)
		btn.pressed.connect(_on_card_picked.bind(card))
		container.add_child(btn)


func _show_phase_two() -> void:
	if _phase_two_root:
		_phase_two_root.visible = true
	if _continue_btn:
		_continue_btn.disabled = false


func _on_reroll() -> void:
	if _card_row == null or _reroll_used or context == null or context.economy == null:
		return
	if not context.economy.spend_sacred_fire(REROLL_SF_COST):
		if context.bridge:
			context.bridge.alert_message.emit("Need Sacred Fire to reroll", 40)
		return
	_reroll_used = true
	_card_picked = false
	if _phase_two_root:
		_phase_two_root.visible = false
	if _continue_btn:
		_continue_btn.disabled = true
	_populate_cards(_card_row)


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
					context.map_light.repair_region_light(str(rid), 15)
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
	_apply_fate_effects(card)
	_card_picked = true
	AnalyticsService.fate_card_selected(card.card_id)
	CombatEvents.fate_card_selected.emit(card.card_id)
	if context.bridge:
		context.bridge.alert_message.emit("Fate chosen: %s" % card.title, 20)
	if context.tutorial_active:
		_finish_draft()
		return
	_show_phase_two()


func _apply_fate_effects(card: FateCardData) -> void:
	if context == null:
		return
	match card.card_id:
		"card_derafsh_oath":
			if context.morale:
				context.morale.add(15)
			if context.economy and card.boon_sacred_fire_bonus > 0:
				context.economy.add_sacred_fire(card.boon_sacred_fire_bonus)
			if card.curse_corruption_rate > 0.0:
				context.runtime_modifiers["corruption_rate_bonus"] = card.curse_corruption_rate
		"card_qanat_blessing":
			context.runtime_modifiers["control_slow_mult"] = 0.4
			if card.boon_gold_bonus != 0:
				context.runtime_modifiers["wave_gold_penalty"] = card.boon_gold_bonus
		"card_lion_s_legacy":
			var grant_gold := false
			if context.wave_manager and context.level_data:
				var next_idx := context.wave_manager.current_wave_index + 1
				if next_idx < context.level_data.waves.size():
					grant_gold = context.level_data.waves[next_idx].is_boss_wave
			if grant_gold and context.economy:
				context.economy.add_gold(card.boon_gold_bonus)
		"card_iron_rain":
			context.runtime_modifiers["tower_attack_rate_mult"] = 1.2
			context.runtime_modifiers["attack_mult"] = card.boon_attack_mult
			context.runtime_modifiers["enemy_speed_mult"] = 1.05
			if card.curse_enemy_hp_mult != 1.0:
				context.runtime_modifiers["enemy_hp_mult"] = card.curse_enemy_hp_mult
		_:
			_apply_default_fate_effects(card)


func _apply_default_fate_effects(card: FateCardData) -> void:
	if card.boon_gold_bonus > 0 and context.economy:
		context.economy.add_gold(card.boon_gold_bonus)
	if card.boon_gold_bonus < 0 and context.economy:
		context.runtime_modifiers["wave_gold_penalty"] = card.boon_gold_bonus
	if card.boon_sacred_fire_bonus > 0 and context.economy:
		context.economy.add_sacred_fire(card.boon_sacred_fire_bonus)
	if card.boon_attack_mult != 1.0:
		context.runtime_modifiers["attack_mult"] = card.boon_attack_mult
	if card.curse_enemy_hp_mult != 1.0:
		context.runtime_modifiers["enemy_hp_mult"] = card.curse_enemy_hp_mult
	if card.curse_corruption_rate > 0.0:
		context.runtime_modifiers["corruption_rate_bonus"] = card.curse_corruption_rate


func _on_continue_pressed() -> void:
	if not _card_picked:
		if context and context.bridge:
			context.bridge.alert_message.emit("Choose a Fate card first", 50)
		return
	_finish_draft()


func _can_retreat_to_forge() -> bool:
	if context == null or context.launch_data == null:
		return false
	if context.tutorial_active:
		return false
	var launch: BattleLaunchData = context.launch_data
	return launch.is_campaign_run or launch.is_campaign_mode() or launch.is_horde_mode


func _on_retreat_pressed() -> void:
	if context == null or context.state_controller == null:
		return
	if _panel:
		_panel.visible = false
		_clear_content_root()
	context.state_controller.trigger_safe_retreat("safe_retreat")


func _finish_draft() -> void:
	if _panel:
		_panel.visible = false
		_clear_content_root()
	if context and context.state_controller:
		context.state_controller.resume_battle()
