class_name BattleHudController
extends CanvasLayer
const ALERT_DISPLAY_SEC := 2.5
var context: BattleContext = null
var _fate_draft: FateDraftController = null
var _vow_offer: VowOfferController = null
var _vow_label: Label = null
var _tower_radial: TowerRadialBuildController = null
var _last_victory: bool = false
var _tutorial_gating: bool = false
var _last_tutorial_allowed: PackedStringArray = PackedStringArray()
var _pending_victory: bool = false
var _pending_reason: String = ""
var _pending_summary: Dictionary = {}
var _user_pause_modal_visible: bool = false
@onready var _gold_label: Label = %GoldLabel
@onready var _sf_label: Label = %SacredFireLabel
@onready var _lives_label: Label = %LivesLabel
@onready var _wave_label: Label = %WaveLabel
@onready var _morale_label: Label = %MoraleLabel
@onready var _alert_label: Label = %AlertLabel
@onready var _next_wave_panel: Panel = %NextWavePanel
@onready var _next_wave_label: Label = %NextWaveLabel
@onready var _early_call_btn: Button = %EarlyCallButton
@onready var _cleanse_hint: Label = %CleanseHintLabel
@onready var _start_btn: Button = %StartWaveButton
@onready var _gauntlet_rush_btn: Button = %GauntletRushButton
@onready var _gauntlet_timer_panel: GauntletHudWidget = %GauntletTimerPanel
@onready var _gauntlet_chain_overlay: Panel = %GauntletChainOverlay
@onready var _gauntlet_chain_label: Label = %GauntletChainLabel
@onready var _pause_btn: Button = %PauseButton
@onready var _speed_btn: Button = %SpeedButton
@onready var _cleanse_btn: Button = %CleanseButton
@onready var _replay_btn: Button = %ReplayButton
@onready var _map_btn: Button = %MapButton
@onready var _results_panel: Panel = %ResultsPanel
@onready var _results_title_label: Label = %ResultsTitleLabel
@onready var _results_reason_label: Label = %ResultsReasonLabel
@onready var _results_rewards_label: Label = %ResultsRewardsLabel
@onready var _results_summary_label: Label = %ResultsSummaryLabel
@onready var _pardeh_panel: Panel = %PardehPanel
@onready var _minimap: MinimapController = %MinimapPanel
@onready var _spell_bar_anchor: Control = %SpellBarAnchor
@onready var _threat_indicator: ThreatIndicatorController = %ThreatIndicators
@onready var _pause_overlay: ColorRect = %PauseOverlay
@onready var _pause_panel: Panel = %PausePanel
@onready var _pause_resume_btn: Button = %PauseResumeButton
@onready var _pause_exit_btn: Button = %PauseExitButton
var _materials_label: Label = null
var _farr_label: Label = null
var _spell_row: HBoxContainer = null
var _spell_buttons: Array[Button] = []
var _coop_row: HBoxContainer = null
var _coop_sf_labels: Array[Label] = []
var _coop_mat_labels: Array[Label] = []
var _coop_skill_buttons: Array[Button] = []
var _coop_portrait_buttons: Array[Button] = []
var _gauntlet_timer: GauntletTimerController = null
var _gauntlet_handling: bool = false
var _hero_action_hud: HeroActionHud = null
var _region_status_hud: RegionStatusHud = null
var _subtitle_overlay: SubtitleOverlay = null
var _gate_flash: ColorRect = null
var _battle_camera: TouchCamera = null
var _last_playable_cam_pos: Vector2 = Vector2(-99999.0, -99999.0)
var _last_playable_cam_zoom: float = -1.0
var _last_lives: int = -1
var _gate_flash_tween: Tween = null
var _lives_flash_tween: Tween = null
var _alert_queue: Array[Dictionary] = []
var _alert_current_prio: int = -1
var _alert_timer: float = 0.0
var _objective_chip: Label = null
var _boss_hp_panel: PanelContainer = null
var _boss_hp_bar: ProgressBar = null
var _boss_name_label: Label = null
var _pause_restart_btn: Button = null
var _pause_settings_btn: Button = null
var _settings_panel: Control = null
var _settings_scene: PackedScene = preload("res://scenes/ui/settings_panel.tscn")
func initialize(ctx: BattleContext, fate_draft: FateDraftController, vow_offer: VowOfferController = null) -> void:
	context = ctx
	_fate_draft = fate_draft
	_vow_offer = vow_offer
	if ctx.tower_manager:
		ctx.tower_manager.tower_opened.connect(_on_tower_opened)
		ctx.tower_manager.build_radial_requested.connect(_on_build_radial_requested)
	if ctx.bridge:
		ctx.bridge.gold_changed.connect(_on_gold)
		ctx.bridge.sacred_fire_changed.connect(_on_sf)
		ctx.bridge.lives_changed.connect(_on_lives)
		ctx.bridge.wave_changed.connect(_on_wave)
		ctx.bridge.alert_message.connect(_on_alert)
		ctx.bridge.battle_state_changed.connect(_on_state)
		ctx.bridge.pardeh_break_requested.connect(_on_pardeh)
		ctx.bridge.vow_offer_requested.connect(_on_vow_offer)
		ctx.bridge.vow_status.connect(_on_vow_status)
		ctx.bridge.results_requested.connect(_on_results)
		ctx.bridge.morale_changed.connect(_on_morale)
		ctx.bridge.run_summary_ready.connect(_on_run_summary)
		ctx.bridge.region_selected.connect(_on_region_selected)
		ctx.bridge.region_light_changed.connect(_on_region_light_changed)
		ctx.bridge.intermission_started.connect(_on_intermission_started)
		ctx.bridge.intermission_ended.connect(_on_intermission_ended)
		ctx.bridge.materials_changed.connect(_on_materials)
	_setup_materials_label()
	_setup_farr_label()
	_on_gold(ctx.economy.gold if ctx.economy else 0)
	_on_sf(ctx.economy.sacred_fire if ctx.economy else 0)
	_on_lives(ctx.lives.current_lives if ctx.lives else 0, ctx.lives.max_lives if ctx.lives else 0)
	_refresh_cleanse_hint()
	_apply_compact_hud_styles()
	_setup_tower_radial()
	setup_spell_bar(ctx)
	_setup_hero_action_hud()
	_apply_hud_layout()
	_setup_region_status_hud()
	_setup_subtitle_overlay()
	_setup_gate_feedback()
	if context.launch_data and context.launch_data.is_gauntlet_mode:
		_setup_gauntlet_mode(ctx)
	if _results_panel:
		_results_panel.visible = false
	if _pardeh_panel:
		_pardeh_panel.visible = false
	_setup_vow_label()
	_setup_objective_chip()
	_setup_boss_hp_bar()
	_setup_pause_extras()
	_apply_accessibility_scale()
	_apply_accessibility_theme()
	if _replay_btn:
		_replay_btn.visible = false
	if _map_btn:
		_map_btn.visible = false
	_hide_pause_modal()
	_update_start_wave_visibility(
		context.state_controller.current_state if context and context.state_controller else GameEnums.BattleState.PRE_BATTLE
	)
func setup_brothers_hud() -> void:
	if context == null or context.coop_players == null or not context.coop_players.is_active():
		return
	if _coop_row != null:
		return
	var top := get_node_or_null("TopBarPanel/TopBarRoot/TopBarContext") as Control
	if top == null:
		top = get_node_or_null("TopBarPanel/TopBarRoot/TopBar") as Control
	if top == null:
		return
	_coop_row = HBoxContainer.new()
	_coop_row.name = "CoopHudRow"
	_coop_row.add_theme_constant_override("separation", 16)
	top.add_child(_coop_row)
	for i in context.coop_players.slots.size():
		var slot := context.coop_players.slots[i]
		var col := VBoxContainer.new()
		col.add_theme_constant_override("separation", 2)
		var hero := ContentRegistry.get_hero(slot.hero_id)
		var portrait := Button.new()
		portrait.text = "P%d %s" % [i + 1, hero.display_name if hero else slot.hero_id]
		portrait.custom_minimum_size = Vector2(120, 28)
		portrait.pressed.connect(_on_coop_portrait_pressed.bind(i))
		col.add_child(portrait)
		_coop_portrait_buttons.append(portrait)
		var sf_label := Label.new()
		sf_label.add_theme_font_size_override("font_size", 11)
		sf_label.text = "SF: %d" % slot.sacred_fire
		col.add_child(sf_label)
		_coop_sf_labels.append(sf_label)
		var mat_label := Label.new()
		mat_label.add_theme_font_size_override("font_size", 10)
		mat_label.text = "Loot: —"
		col.add_child(mat_label)
		_coop_mat_labels.append(mat_label)
		var skill_btn := Button.new()
		skill_btn.custom_minimum_size = Vector2(120, 30)
		skill_btn.add_theme_font_size_override("font_size", 10)
		skill_btn.text = _skill_label_for_hero(slot.hero_id)
		skill_btn.pressed.connect(_on_coop_skill_pressed.bind(i))
		col.add_child(skill_btn)
		_coop_skill_buttons.append(skill_btn)
		_coop_row.add_child(col)
	var bottom := get_node_or_null("BottomBar") as Control
	if bottom:
		bottom.visible = false
	if _sf_label:
		_sf_label.visible = false
	if _materials_label:
		_materials_label.visible = false
	context.coop_players.sacred_fire_changed.connect(_on_coop_sf_changed)
	context.coop_players.materials_changed.connect(_on_coop_materials_changed)
	context.coop_players.focused_slot_changed.connect(_on_coop_focus_changed)
	_refresh_coop_hud()
	_on_coop_focus_changed(context.coop_players.focused_player_index)


func _skill_label_for_hero(hero_id: String) -> String:
	match hero_id:
		"zal":
			return "Zal Foresight"
		"sohrab":
			return "Sohrab Rage"
		_:
			return "Skill"


func _on_coop_portrait_pressed(player_index: int) -> void:
	if context and context.coop_players:
		context.coop_players.set_focused_slot(player_index)


func _on_coop_skill_pressed(player_index: int) -> void:
	if context == null or context.hero_manager == null:
		return
	var hero := context.hero_manager.get_hero_for_slot(player_index)
	if hero:
		hero.use_skill()


func _on_coop_sf_changed(player_index: int, amount: int) -> void:
	if player_index >= 0 and player_index < _coop_sf_labels.size():
		_coop_sf_labels[player_index].text = "SF: %d" % amount
	if context and context.coop_players and player_index == context.coop_players.focused_player_index:
		_on_sf(amount)


func _on_coop_materials_changed(player_index: int, materials: Dictionary) -> void:
	if player_index < 0 or player_index >= _coop_mat_labels.size():
		return
	if materials.is_empty():
		_coop_mat_labels[player_index].text = "Loot: —"
		return
	var parts: PackedStringArray = PackedStringArray()
	for mat_id in materials.keys():
		parts.append("%s x%d" % [mat_id, int(materials.get(mat_id, 0))])
	_coop_mat_labels[player_index].text = "Loot: %s" % ", ".join(parts)


func _on_coop_focus_changed(player_index: int) -> void:
	for i in _coop_portrait_buttons.size():
		var btn := _coop_portrait_buttons[i]
		btn.modulate = Color(1.2, 1.15, 0.85) if i == player_index else Color.WHITE
	if context and context.coop_players:
		var slot := context.coop_players.get_slot(player_index)
		if slot:
			_on_sf(slot.sacred_fire)
	_refresh_cleanse_hint()


func _refresh_coop_hud() -> void:
	if context == null or context.coop_players == null:
		return
	for i in context.coop_players.slots.size():
		var slot := context.coop_players.slots[i]
		_on_coop_sf_changed(i, slot.sacred_fire)
		_on_coop_materials_changed(i, slot.get_unbanked_materials())


func _ready() -> void:
	if _start_btn:
		_start_btn.pressed.connect(_on_start)
	if _pause_btn:
		_pause_btn.pressed.connect(_on_pause)
	if _speed_btn:
		_speed_btn.pressed.connect(_on_speed)
	if _cleanse_btn:
		_cleanse_btn.pressed.connect(_on_cleanse)
	if _replay_btn:
		_replay_btn.pressed.connect(_on_replay)
	if _map_btn:
		_map_btn.pressed.connect(_on_map)
	if _early_call_btn:
		_early_call_btn.pressed.connect(_on_early_call)
	if _gauntlet_rush_btn:
		_gauntlet_rush_btn.pressed.connect(_on_gauntlet_rush)
	if _pause_resume_btn:
		_pause_resume_btn.pressed.connect(_on_pause_resume)
	if _pause_exit_btn:
		_pause_exit_btn.pressed.connect(_on_pause_exit)
func _setup_gauntlet_mode(ctx: BattleContext) -> void:
	if _gauntlet_rush_btn:
		_gauntlet_rush_btn.visible = true
	_gauntlet_timer = GauntletTimerController.new()
	_gauntlet_timer.name = "GauntletTimerController"
	add_child(_gauntlet_timer)
	_gauntlet_timer.initialize(ctx, _gauntlet_timer_panel)
	if ctx.bridge:
		ctx.bridge.alert_message.emit("Haft-Khan Gauntlet — beat your ghost!", 95)


func _on_gauntlet_rush() -> void:
	if context == null or context.wave_manager == null:
		return
	context.wave_manager.request_pre_battle_rush()
	if _gauntlet_rush_btn:
		_gauntlet_rush_btn.disabled = true
	if _start_btn:
		_start_btn.disabled = true


func get_highlight_target(key: String) -> Control:
	if _hero_action_hud:
		var action_target: Control = _hero_action_hud.get_highlight_control(key)
		if action_target:
			return action_target
	match key:
		"build_pads":
			return _start_btn
		"start_wave":
			return _start_btn
		"skill":
			return _hero_action_hud.get_highlight_control("skill") if _hero_action_hud else null
		"naft":
			return _hero_action_hud.get_highlight_control("naft") if _hero_action_hud else null
		"cleanse":
			return _cleanse_btn
		"gold":
			return _gold_label
		"materials":
			return _materials_label if _materials_label else _gold_label
		"sacred_fire":
			return _sf_label
		"lives":
			return _lives_label
		"morale":
			return _morale_label
		"pause":
			return _pause_btn
		"speed":
			return _speed_btn
		"pause_speed":
			return _pause_btn
		"fate_draft":
			return _pardeh_panel
	return null
func setup_spell_bar(ctx: BattleContext) -> void:
	if _spell_row != null:
		return
	var anchor := _spell_bar_anchor
	if anchor == null:
		anchor = get_node_or_null("SpellBarAnchor") as Control
	if anchor == null:
		return
	_spell_row = HBoxContainer.new()
	_spell_row.name = "SpellBar"
	_spell_row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_spell_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_spell_row.add_theme_constant_override("separation", 6)
	anchor.add_child(_spell_row)
	_refresh_spell_buttons(ctx)


func _refresh_spell_buttons(ctx: BattleContext) -> void:
	if _spell_row == null:
		return
	for btn in _spell_buttons:
		btn.queue_free()
	_spell_buttons.clear()
	if ctx == null or ctx.spell_controller == null:
		return
	for spell in ctx.spell_controller.get_owned_spells():
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(88, 36)
		btn.add_theme_font_size_override("font_size", 10)
		btn.text = spell.display_name
		btn.pressed.connect(_on_spell_pressed.bind(spell.spell_id))
		_spell_row.add_child(btn)
		_spell_buttons.append(btn)


func _on_spell_pressed(spell_id: String) -> void:
	if context == null or context.spell_controller == null:
		return
	if context.spell_controller.is_on_cooldown(spell_id):
		var remaining := context.spell_controller.cooldown_remaining(spell_id)
		_on_alert("Spell cooling: %.0fs" % remaining, 40)
		return
	if context.spell_controller.cast_spell(spell_id):
		for btn in _spell_buttons:
			btn.disabled = false
	else:
		_on_alert("Cannot cast spell", 40)


func _process(_delta: float) -> void:
	_tick_alert_queue(_delta)
	_tick_playable_hud_layout()
	if _hero_action_hud:
		_hero_action_hud.refresh_action_buttons()
		_hero_action_hud.refresh_hero_chip()
	_refresh_boss_hp()
	if context == null or context.spell_controller == null or _spell_buttons.is_empty():
		return
	for i in _spell_buttons.size():
		var btn := _spell_buttons[i]
		var spell_id := ""
		if context.spell_controller.get_owned_spells().size() > i:
			spell_id = context.spell_controller.get_owned_spells()[i].spell_id
		if spell_id == "":
			continue
		var on_cd := context.spell_controller.is_on_cooldown(spell_id)
		btn.disabled = on_cd
		if on_cd:
			btn.text = "%.0fs" % context.spell_controller.cooldown_remaining(spell_id)
		else:
			var spell := ContentRegistry.get_spell(spell_id)
			btn.text = spell.display_name if spell else spell_id


func setup_camera_ui(camera: TouchCamera) -> void:
	_battle_camera = camera
	if _minimap and camera:
		_minimap.initialize(context, camera)
		_minimap.visible = true
		_minimap.set_interactive(not camera.is_camera_locked())
	if _threat_indicator and camera:
		_threat_indicator.initialize(context, camera)
		_threat_indicator.visible = not camera.is_camera_locked()
	if _tower_radial:
		_tower_radial.camera = camera
	_last_playable_cam_pos = Vector2(-99999.0, -99999.0)
	_last_playable_cam_zoom = -1.0
	_update_playable_hud_layout()


func _update_playable_hud_layout() -> void:
	if _hero_action_hud == null:
		return
	var vp := get_viewport()
	if _battle_camera and vp:
		var rect := MapCameraUtils.playable_screen_rect(vp, _battle_camera)
		_hero_action_hud.apply_playable_rect(rect)
	elif vp:
		_hero_action_hud.apply_playable_rect(Rect2(Vector2.ZERO, vp.get_visible_rect().size))


func _tick_playable_hud_layout() -> void:
	if _battle_camera == null or _hero_action_hud == null:
		return
	var pos := _battle_camera.global_position
	var z := _battle_camera.zoom.x
	if pos.is_equal_approx(_last_playable_cam_pos) and is_equal_approx(z, _last_playable_cam_zoom):
		return
	_last_playable_cam_pos = pos
	_last_playable_cam_zoom = z
	_update_playable_hud_layout()


func _get_top_bar_context() -> HBoxContainer:
	return get_node_or_null("TopBarPanel/TopBarRoot/TopBarContext") as HBoxContainer


func _apply_context_label_style(label: Label) -> void:
	label.add_theme_font_size_override("font_size", 11)
	label.clip_text = true
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL


func _update_start_wave_visibility(state: GameEnums.BattleState) -> void:
	if _start_btn == null:
		return
	_start_btn.visible = state == GameEnums.BattleState.PRE_BATTLE


func _apply_hud_layout() -> void:
	if _spell_bar_anchor:
		_spell_bar_anchor.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
		_spell_bar_anchor.offset_left = -320.0
		_spell_bar_anchor.offset_top = -48.0
		_spell_bar_anchor.offset_right = 320.0
		_spell_bar_anchor.offset_bottom = -8.0
	var top_panel := get_node_or_null("TopBarPanel") as Control
	if top_panel:
		top_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
		top_panel.offset_left = 8.0
		top_panel.offset_top = 8.0
		top_panel.offset_right = -216.0
		top_panel.offset_bottom = 68.0
	if _minimap:
		_minimap.custom_minimum_size = MinimapController.PANEL_SIZE
	if _hero_action_hud:
		_hero_action_hud.apply_layout(AccessibilityHelper.is_left_handed())


func _apply_compact_hud_styles() -> void:
	var compact_font := 11
	for label in [_gold_label, _sf_label, _lives_label, _wave_label, _morale_label, _alert_label]:
		if label:
			label.add_theme_font_size_override("font_size", compact_font)
	if _cleanse_hint:
		_cleanse_hint.add_theme_font_size_override("font_size", 10)
	for btn in [_pause_btn, _speed_btn, _cleanse_btn]:
		if btn:
			btn.custom_minimum_size = Vector2(44, 36)
			btn.add_theme_font_size_override("font_size", compact_font)
	if _start_btn:
		_start_btn.add_theme_font_size_override("font_size", compact_font)


func _setup_tower_radial() -> void:
	if _tower_radial != null:
		return
	_tower_radial = TowerRadialBuildController.new()
	_tower_radial.name = "TowerRadialBuildController"
	add_child(_tower_radial)
	if context:
		var cam := get_viewport().get_camera_2d()
		_tower_radial.initialize(context, cam)


func setup_tower_range_ring(ring: TowerRangeRing) -> void:
	_setup_tower_radial()
	if _tower_radial:
		_tower_radial.set_range_ring(ring)


func _on_build_radial_requested(world_pos: Vector2, region_id: String) -> void:
	if _tower_radial:
		_tower_radial.show_for_position(world_pos, region_id)


func is_tower_radial_open() -> bool:
	return _tower_radial != null and _tower_radial.visible
func apply_tutorial_gating(allowed: PackedStringArray) -> void:
	_tutorial_gating = true
	_last_tutorial_allowed = allowed
	var allow: Dictionary = {}
	for key in allowed:
		allow[key] = true
	_set_control_enabled(_start_btn, allow.get("start_wave", false))
	_set_control_enabled(_pause_btn, allow.get("pause", false) or allow.get("pause_speed", false))
	_set_control_enabled(_speed_btn, allow.get("speed", false) or allow.get("pause_speed", false))
	_set_control_enabled(_cleanse_btn, allow.get("cleanse", false))
	if _hero_action_hud:
		_hero_action_hud.apply_tutorial_gating(allow)
func clear_tutorial_gating() -> void:
	_tutorial_gating = false
	_last_tutorial_allowed = PackedStringArray()
	_set_control_enabled(_start_btn, true)
	_set_control_enabled(_pause_btn, true)
	_set_control_enabled(_speed_btn, true)
	_set_control_enabled(_cleanse_btn, true)
	if _hero_action_hud:
		_hero_action_hud.clear_tutorial_gating()


func get_move_vector() -> Vector2:
	if _hero_action_hud:
		return _hero_action_hud.get_move_vector()
	return Vector2.ZERO


func _setup_hero_action_hud() -> void:
	if _hero_action_hud != null or context == null:
		return
	_hero_action_hud = HeroActionHud.new()
	_hero_action_hud.name = "HeroActionHud"
	add_child(_hero_action_hud)
	_hero_action_hud.setup(context)
	_hero_action_hud.attack_pressed.connect(_on_attack)
	_hero_action_hud.heavy_pressed.connect(_on_heavy)
	_hero_action_hud.dodge_pressed.connect(_on_dodge)
	_hero_action_hud.skill_pressed.connect(_on_skill)
	_hero_action_hud.naft_pressed.connect(_on_naft)
	_hero_action_hud.mount_pressed.connect(_on_mount)


func _setup_objective_chip() -> void:
	if _objective_chip != null or context == null:
		return
	_objective_chip = Label.new()
	_objective_chip.name = "ObjectiveChip"
	_objective_chip.add_theme_font_size_override("font_size", 11)
	_objective_chip.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
	_apply_context_label_style(_objective_chip)
	var top := _get_top_bar_context()
	if top == null:
		top = get_node_or_null("TopBarPanel/TopBarRoot/TopBar") as HBoxContainer
	if top:
		top.add_child(_objective_chip)
	if context.objectives and context.objectives.active_objective:
		_objective_chip.text = "Goal: %s" % context.objectives.active_objective.title


func _setup_boss_hp_bar() -> void:
	if _boss_hp_panel != null:
		return
	_boss_hp_panel = PanelContainer.new()
	_boss_hp_panel.name = "BossHpPanel"
	_boss_hp_panel.visible = false
	_boss_hp_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_boss_hp_panel.offset_top = 80.0
	_boss_hp_panel.offset_bottom = 110.0
	_boss_hp_panel.offset_left = 280.0
	_boss_hp_panel.offset_right = -280.0
	add_child(_boss_hp_panel)
	var box := VBoxContainer.new()
	_boss_hp_panel.add_child(box)
	_boss_name_label = Label.new()
	_boss_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_boss_name_label.add_theme_font_size_override("font_size", 12)
	box.add_child(_boss_name_label)
	_boss_hp_bar = ProgressBar.new()
	_boss_hp_bar.custom_minimum_size = Vector2(400, 16)
	_boss_hp_bar.show_percentage = false
	box.add_child(_boss_hp_bar)


func _setup_pause_extras() -> void:
	var row := _pause_panel.get_node_or_null("MarginContainer/VBoxContainer/ButtonRow") as HBoxContainer
	if row == null:
		return
	_pause_restart_btn = Button.new()
	_pause_restart_btn.text = "Restart"
	_pause_restart_btn.custom_minimum_size = Vector2(120, 40)
	_pause_restart_btn.pressed.connect(_on_pause_restart)
	row.add_child(_pause_restart_btn)
	_pause_settings_btn = Button.new()
	_pause_settings_btn.text = "Settings"
	_pause_settings_btn.custom_minimum_size = Vector2(120, 40)
	_pause_settings_btn.pressed.connect(_on_pause_settings)
	row.add_child(_pause_settings_btn)


func _apply_accessibility_scale() -> void:
	if SettingsService == null:
		return
	var ui_scale := clampf(float(SettingsService.ui_scale), 0.8, 1.4)
	if is_equal_approx(ui_scale, 1.0):
		transform = Transform2D.IDENTITY
		scale = Vector2.ONE
		return
	var vp := get_viewport().get_visible_rect().size if get_viewport() else Vector2(1280, 720)
	var pivot := vp * 0.5
	var xform := Transform2D.IDENTITY.translated(pivot).scaled(Vector2(ui_scale, ui_scale)).translated(-pivot)
	transform = xform
	scale = Vector2.ONE


func _apply_accessibility_theme() -> void:
	var high := AccessibilityHelper.is_high_contrast()
	var label_color := Color(1.0, 1.0, 0.92) if high else Color(0.92, 0.94, 0.98)
	for label in [_gold_label, _sf_label, _lives_label, _wave_label, _morale_label, _alert_label]:
		if label == null:
			continue
		label.add_theme_color_override("font_color", label_color)
		if high:
			label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
			label.add_theme_constant_override("outline_size", 2)
		else:
			label.remove_theme_color_override("font_outline_color")
			label.remove_theme_constant_override("outline_size")


func _setup_region_status_hud() -> void:
	if _region_status_hud != null or context == null:
		return
	_region_status_hud = RegionStatusHud.new()
	add_child(_region_status_hud)
	_region_status_hud.setup(context)


func _setup_subtitle_overlay() -> void:
	if _subtitle_overlay != null:
		return
	_subtitle_overlay = SubtitleOverlay.new()
	add_child(_subtitle_overlay)


func _setup_gate_feedback() -> void:
	if _gate_flash != null:
		return
	_gate_flash = ColorRect.new()
	_gate_flash.name = "GateHitFlash"
	_gate_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_gate_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_gate_flash.color = Color(0.85, 0.12, 0.08, 0.0)
	add_child(_gate_flash)
	move_child(_gate_flash, 0)


func _play_gate_hit_feedback() -> void:
	if _battle_camera:
		_battle_camera.request_shake(7.0)
	if AccessibilityHelper.vibration_enabled():
		Input.vibrate_handheld(120)
	var flash_alpha := 0.42 * AccessibilityHelper.flash_alpha_multiplier()
	if _gate_flash and flash_alpha > 0.02:
		if _gate_flash_tween and _gate_flash_tween.is_valid():
			_gate_flash_tween.kill()
		_gate_flash.color = Color(0.85, 0.12, 0.08, flash_alpha)
		_gate_flash_tween = create_tween()
		_gate_flash_tween.tween_property(_gate_flash, "color:a", 0.0, 0.35)
	if _lives_label:
		if _lives_flash_tween and _lives_flash_tween.is_valid():
			_lives_flash_tween.kill()
		_lives_label.modulate = Color(1.4, 0.45, 0.35)
		_lives_flash_tween = create_tween()
		_lives_flash_tween.tween_property(_lives_label, "modulate", Color.WHITE, 0.45)


func _get_controlled_hero() -> HeroController:
	if context == null or context.hero_manager == null:
		return null
	return context.hero_manager.get_controlled_hero()


func _on_attack() -> void:
	var hero := _get_controlled_hero()
	if hero:
		hero.attack()


func _on_heavy() -> void:
	var hero := _get_controlled_hero()
	if hero:
		hero.heavy_attack()


func _on_dodge() -> void:
	var hero := _get_controlled_hero()
	if hero:
		hero.dodge()


func _on_pause_restart() -> void:
	_hide_pause_modal()
	if context and context.state_controller:
		context.state_controller.resume_battle()
	var launch := _get_current_launch()
	if launch:
		SceneFlowController.go_to_battle(launch.duplicate_launch())


func _on_pause_settings() -> void:
	if _settings_panel == null and _settings_scene:
		_settings_panel = _settings_scene.instantiate() as Control
		if _settings_panel:
			add_child(_settings_panel)
			_settings_panel.visible = false
			if _settings_panel.has_signal("settings_changed"):
				_settings_panel.settings_changed.connect(_on_settings_changed)
	if _settings_panel:
		_settings_panel.visible = not _settings_panel.visible


func _on_settings_changed() -> void:
	_apply_accessibility_scale()
	_apply_accessibility_theme()
	_apply_hud_layout()
	_update_playable_hud_layout()
	if _region_status_hud:
		_region_status_hud.refresh_accessibility()


func _refresh_boss_hp() -> void:
	if _boss_hp_panel == null or context == null:
		return
	var boss: EnemyController = null
	for e in context.active_enemies:
		if e is EnemyController and e.data and e.data.is_boss and e.current_hp > 0.0:
			boss = e
			break
	if boss == null:
		_boss_hp_panel.visible = false
		return
	_boss_hp_panel.visible = true
	if _boss_name_label and boss.data:
		_boss_name_label.text = boss.data.display_name
	if _boss_hp_bar:
		_boss_hp_bar.max_value = boss.get_effective_max_hp()
		_boss_hp_bar.value = boss.current_hp
func _set_control_enabled(control: Control, enabled: bool) -> void:
	if control == null:
		return
	if control is BaseButton:
		(control as BaseButton).disabled = not enabled
	control.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE
func refresh_skill_label() -> void:
	if _hero_action_hud:
		_hero_action_hud.refresh_skill_button_label()


func _on_tower_opened(tower: TowerController) -> void:
	if _tower_radial:
		_tower_radial.show_for_tower(tower)
func _on_naft() -> void:
	if context == null or context.naft_traps == null:
		return
	context.naft_traps.toggle_arm()


func _on_mount() -> void:
	if context == null or context.rakhsh_mount == null:
		return
	context.rakhsh_mount.toggle_mount()


func _on_region_selected(region_id: String, _light: int) -> void:
	_refresh_cleanse_hint()
func _on_region_light_changed(region_id: String, _light: int, _state: GameEnums.RegionLightState) -> void:
	if context and context.map_light and context.map_light.selected_region_id == region_id:
		_refresh_cleanse_hint()
func _refresh_cleanse_hint() -> void:
	if _cleanse_hint == null or context == null or context.map_light == null:
		return
	var ml := context.map_light
	var rid := ml.selected_region_id
	if rid != "":
		_cleanse_hint.text = "Cleanse: %s (%d)" % [rid, ml.get_light(rid)]
	else:
		var auto := ml.get_best_cleanse_target()
		if auto != "":
			_cleanse_hint.text = "Cleanse: auto → %s (%d)" % [auto, ml.get_light(auto)]
		else:
			_cleanse_hint.text = "Cleanse: auto"
func _on_start() -> void:
	if context and context.state_controller:
		context.state_controller.start_battle()
		if _start_btn:
			_start_btn.disabled = true
			_start_btn.visible = false
func _on_pause() -> void:
	if context == null or context.state_controller == null:
		return
	var state := context.state_controller.current_state
	if state != GameEnums.BattleState.WAVE_ACTIVE and state != GameEnums.BattleState.PRE_BATTLE:
		return
	context.state_controller.pause_battle()
	if _gauntlet_timer:
		_gauntlet_timer.pause_timer()
	_show_pause_modal()


func _on_pause_resume() -> void:
	if context == null or context.state_controller == null:
		return
	_hide_pause_modal()
	if context.state_controller.current_state == GameEnums.BattleState.PAUSED:
		context.state_controller.resume_battle()
	if _gauntlet_timer:
		_gauntlet_timer.resume_timer()


func _on_pause_exit() -> void:
	_hide_pause_modal()
	var level_id := context.level_data.level_id if context and context.level_data else "level_01"
	AnalyticsService.battle_exit_to_map(level_id, false)
	SceneFlowController.go_to_world_map()


func _show_pause_modal() -> void:
	_user_pause_modal_visible = true
	if _pause_overlay:
		_pause_overlay.visible = true
	if _pause_panel:
		_pause_panel.visible = true


func _hide_pause_modal() -> void:
	_user_pause_modal_visible = false
	if _pause_overlay:
		_pause_overlay.visible = false
	if _pause_panel:
		_pause_panel.visible = false


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		_update_playable_hud_layout()
	elif what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_handle_back_pressed()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_handle_back_pressed()
		get_viewport().set_input_as_handled()


func _handle_back_pressed() -> void:
	if context and context.naft_traps and context.naft_traps.is_armed():
		context.naft_traps.disarm()
		return
	if _tower_radial and _tower_radial.visible:
		_tower_radial.hide_menu()
		return
	if _user_pause_modal_visible:
		_on_pause_resume()
		return
	if _can_user_pause():
		_on_pause()


func _can_user_pause() -> bool:
	if context == null or context.state_controller == null:
		return false
	var state := context.state_controller.current_state
	return state == GameEnums.BattleState.WAVE_ACTIVE \
		or state == GameEnums.BattleState.PRE_BATTLE


func _on_speed() -> void:
	if context == null or context.state_controller == null:
		return
	var mult := 2.0 if context.state_controller.speed_multiplier < 1.5 else 1.0
	context.state_controller.set_speed_multiplier(mult)
	if _speed_btn:
		_speed_btn.text = "%dx" % int(mult)
func _on_cleanse() -> void:
	if context and context.map_light:
		context.map_light.try_cleanse_selected()
func _on_skill() -> void:
	var hero := _get_controlled_hero()
	if hero:
		hero.use_skill()


func _on_replay() -> void:
	var launch := _get_current_launch()
	var level_id: String = "level_01"
	if launch:
		level_id = launch.level_id
	elif context and context.level_data:
		level_id = context.level_data.level_id
	if context and context.level_data and context.level_data.is_tutorial:
		if _last_victory and SaveSystem and not SaveSystem.is_tutorial_completed():
			SaveSystem.mark_tutorial_completed()
			SceneFlowController.go_to_world_map()
		elif not _last_victory:
			if launch:
				SceneFlowController.go_to_battle(launch.duplicate_launch())
			else:
				var fresh := BattleLaunchData.new()
				fresh.level_id = "level_00_tutorial"
				SceneFlowController.go_to_battle(fresh)
		else:
			SceneFlowController.go_to_world_map()
		return
	AnalyticsService.replay_selected(level_id)
	if SaveSystem:
		SaveSystem.record_replay(level_id)
	if launch:
		SceneFlowController.go_to_battle(launch.duplicate_launch())
	else:
		var fresh := BattleLaunchData.new()
		fresh.level_id = level_id
		SceneFlowController.go_to_battle(fresh)


func _get_current_launch() -> BattleLaunchData:
	if context and context.launch_data:
		return context.launch_data
	if SceneFlowController:
		return SceneFlowController.pending_launch
	return null
func _on_map() -> void:
	var level_id := context.level_data.level_id if context and context.level_data else "level_01"
	AnalyticsService.battle_exit_to_map(level_id, _last_victory)
	var launch := _get_current_launch()
	if launch and launch.is_gauntlet_mode:
		SceneFlowController.clear_gauntlet_run()
		SceneFlowController.go_to_world_map()
		return
	if launch and launch.is_campaign_run and SceneFlowController:
		var safe_retreat := _pending_reason == "safe_retreat"
		SceneFlowController.pending_campaign_battle_result = {
			"victory": _last_victory or safe_retreat,
			"node_id": launch.campaign_node_id,
			"safe_retreat": safe_retreat,
		}
		SceneFlowController.go_to_world_map()
		return
	if launch and launch.is_roguelite_run:
		if _last_victory and SceneFlowController.pending_roguelite_run:
			if SceneFlowController.pending_roguelite_run.advance():
				SceneFlowController.persist_roguelite_run()
				SceneFlowController.go_to_roguelite_map()
			else:
				SceneFlowController.clear_roguelite_run()
				SceneFlowController.go_to_world_map()
		else:
			SceneFlowController.clear_roguelite_run()
			if _results_summary_label:
				var extra := _results_summary_label.text
				if not extra.is_empty():
					extra += "\n"
				_results_summary_label.text = extra + "Roguelite run ended."
			SceneFlowController.go_to_world_map()
		return
	if launch and launch.is_endless_mode and not _last_victory and context and context.wave_manager:
		SaveSystem.set_endless_best(context.wave_manager.get_endless_wave_count())
	SceneFlowController.go_to_world_map()
func _on_gold(v: int) -> void:
	if _gold_label:
		_gold_label.text = "Gold: %d" % v
	if _tower_radial and _tower_radial.visible:
		_tower_radial.refresh_affordability()
func _on_sf(v: int) -> void:
	if _sf_label:
		_sf_label.text = "Sacred Fire: %d" % v


func _setup_farr_label() -> void:
	var top := _get_top_bar_context()
	if top == null:
		return
	_farr_label = Label.new()
	_farr_label.name = "FarrLabel"
	_apply_context_label_style(_farr_label)
	top.add_child(_farr_label)
	_refresh_farr_label()


func _refresh_farr_label() -> void:
	if _farr_label == null:
		return
	var bal := FarrService.get_balance() if FarrService else 0
	_farr_label.text = "Farr: %d" % bal
	var show_farr := bal > 0
	if not show_farr and context != null and context.launch_data != null:
		show_farr = context.launch_data.is_campaign_mode()
	_farr_label.visible = show_farr


func _setup_materials_label() -> void:
	var top := _get_top_bar_context()
	if top == null:
		return
	_materials_label = Label.new()
	_materials_label.name = "MaterialsLabel"
	_apply_context_label_style(_materials_label)
	top.add_child(_materials_label)
	_on_materials(context.economy.get_unbanked_materials() if context and context.economy else {})


func _on_materials(unbanked: Dictionary) -> void:
	if _materials_label == null:
		return
	if unbanked.is_empty():
		_materials_label.text = "Materials: —"
		return
	var parts: PackedStringArray = PackedStringArray()
	for mat_id in unbanked.keys():
		var mat_name := ForgeService.get_material_name(str(mat_id)) if ForgeService else str(mat_id)
		parts.append("%s %d" % [mat_name, int(unbanked[mat_id])])
	_materials_label.text = "Materials: %s" % ", ".join(parts)
func _on_lives(c: int, m: int) -> void:
	if _lives_label:
		_lives_label.text = "Lives: %d/%d" % [c, m]
	if _last_lives >= 0 and c < _last_lives:
		_play_gate_hit_feedback()
	_last_lives = c
func _on_wave(c: int, t: int) -> void:
	if _wave_label:
		_wave_label.text = "Wave: %d/%d" % [c, t]
func _on_morale(current: int, max_m: int) -> void:
	if _morale_label:
		_morale_label.text = "Morale: %d/%d" % [current, max_m]
func _on_run_summary(summary: Dictionary) -> void:
	_pending_summary = summary
	_try_populate_results_panel()


func _try_populate_results_panel() -> void:
	if _pending_reason.is_empty() or _pending_summary.is_empty():
		return
	_populate_results_panel(_pending_victory, _pending_reason, _pending_summary)


func _populate_results_panel(victory: bool, reason: String, summary: Dictionary) -> void:
	if _results_title_label:
		_results_title_label.text = "Victory!" if victory else "Defeat"
	if _results_reason_label:
		_results_reason_label.text = BattleResultsFormatter.format_reason(reason)
	if _results_rewards_label:
		var rewards := ""
		if victory and context and context.economy:
			rewards = BattleResultsFormatter.format_rewards(context.economy)
		_results_rewards_label.text = rewards
		_results_rewards_label.visible = not rewards.is_empty()
	if _results_summary_label:
		_results_summary_label.text = BattleResultsFormatter.format_summary(summary, context, victory)
func _on_alert(msg: String, prio: int) -> void:
	if _alert_label == null or msg.is_empty():
		return
	if _alert_timer <= 0.0 or prio >= _alert_current_prio:
		_show_alert(msg, prio)
	else:
		_alert_queue.append({"msg": msg, "prio": prio})
		_alert_queue.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			return int(a.get("prio", 0)) > int(b.get("prio", 0))
		)


func _show_alert(msg: String, prio: int) -> void:
	_alert_current_prio = prio
	_alert_timer = ALERT_DISPLAY_SEC
	if _alert_label:
		_alert_label.text = msg
	if _subtitle_overlay:
		_subtitle_overlay.show_subtitle(msg)


func _tick_alert_queue(delta: float) -> void:
	if _alert_timer <= 0.0:
		return
	_alert_timer -= delta
	if _alert_timer > 0.0:
		return
	_alert_current_prio = -1
	if _alert_label:
		_alert_label.text = ""
	if _alert_queue.is_empty():
		return
	var next: Dictionary = _alert_queue.pop_front()
	_show_alert(str(next.get("msg", "")), int(next.get("prio", 0)))


func _on_intermission_started(preview_text: String, max_bonus_gold: int) -> void:
	if _next_wave_panel:
		_next_wave_panel.visible = true
	if _next_wave_label:
		_next_wave_label.text = preview_text
	if _early_call_btn:
		if _is_gauntlet_active():
			_early_call_btn.text = "Start Now — swells!"
		else:
			_early_call_btn.text = "Start Now (+%d gold)" % max_bonus_gold
		_early_call_btn.disabled = false


func _on_intermission_ended() -> void:
	if _next_wave_panel:
		_next_wave_panel.visible = false


func _on_early_call() -> void:
	if context and context.wave_manager:
		context.wave_manager.request_early_call()
	if _early_call_btn:
		_early_call_btn.disabled = true
func _on_state(state: GameEnums.BattleState) -> void:
	if state == GameEnums.BattleState.VICTORY or state == GameEnums.BattleState.DEFEAT:
		_hide_pause_modal()
	_update_start_wave_visibility(state)
	if state == GameEnums.BattleState.PRE_BATTLE and _start_btn and not _tutorial_gating:
		_start_btn.disabled = false
		if _is_gauntlet_active() and _gauntlet_rush_btn:
			_gauntlet_rush_btn.disabled = false
	elif state == GameEnums.BattleState.PRE_BATTLE and _tutorial_gating:
		apply_tutorial_gating(_last_tutorial_allowed)
	elif state == GameEnums.BattleState.WAVE_ACTIVE and _gauntlet_rush_btn and _is_gauntlet_active():
		_gauntlet_rush_btn.disabled = true
	if _tower_radial and _tower_radial.visible:
		_tower_radial.refresh_affordability()
func _on_pardeh() -> void:
	if _fate_draft:
		_fate_draft.show_draft()
	if _pardeh_panel:
		_pardeh_panel.visible = true
	if _tower_radial:
		_tower_radial.hide_menu()


func _on_vow_offer(vow_data: ObjectiveData, block_start: int, block_end: int) -> void:
	if _vow_offer:
		_vow_offer.show_offer(vow_data, block_start, block_end)
	if _pardeh_panel:
		_pardeh_panel.visible = true
	if _tower_radial:
		_tower_radial.hide_menu()


func _setup_vow_label() -> void:
	if _vow_label != null:
		return
	var top_bar := _get_top_bar_context()
	if top_bar == null:
		return
	_vow_label = Label.new()
	_vow_label.name = "VowLabel"
	_vow_label.text = ""
	_apply_context_label_style(_vow_label)
	_vow_label.modulate = Color(0.85, 0.75, 0.45)
	top_bar.add_child(_vow_label)


func _on_vow_status(text: String, state: int) -> void:
	if _vow_label == null:
		return
	if text.is_empty():
		_vow_label.text = ""
		return
	_vow_label.text = text
	match state:
		ObjectiveController.VOW_STATE_BROKEN:
			_vow_label.modulate = Color(0.9, 0.35, 0.35)
		ObjectiveController.VOW_STATE_HONORED:
			_vow_label.modulate = Color(0.45, 0.85, 0.55)
		_:
			_vow_label.modulate = Color(0.85, 0.75, 0.45)
func _on_results(victory: bool, reason: String) -> void:
	_hide_pause_modal()
	_last_victory = victory
	_pending_victory = victory
	_pending_reason = reason
	_pending_summary = {}
	var launch := _get_current_launch()
	if launch and launch.is_gauntlet_mode:
		_handle_gauntlet_results(victory)
		return
	if _tower_radial:
		_tower_radial.hide_menu()
	if _results_panel:
		_results_panel.visible = true
	if _alert_label:
		_alert_label.text = ""
	var is_tutorial := context and context.level_data and context.level_data.is_tutorial
	if _results_title_label:
		_results_title_label.text = "Victory!" if victory else "Defeat"
	AudioManager.play_sfx("victory" if victory else "defeat")
	if _results_reason_label:
		_results_reason_label.text = BattleResultsFormatter.format_reason(reason)
	if _results_rewards_label:
		_results_rewards_label.text = ""
		_results_rewards_label.visible = false
	if _results_summary_label:
		_results_summary_label.text = ""
	if _replay_btn:
		_replay_btn.visible = true
		_replay_btn.text = "Continue" if is_tutorial else "Replay"
	if _map_btn:
		_map_btn.visible = not is_tutorial
	_try_populate_results_panel()


func _is_gauntlet_active() -> bool:
	return context != null and context.launch_data != null and context.launch_data.is_gauntlet_mode


func _handle_gauntlet_results(victory: bool) -> void:
	if _gauntlet_handling:
		return
	_gauntlet_handling = true
	if _tower_radial:
		_tower_radial.hide_menu()
	if _alert_label:
		_alert_label.text = ""
	var run := SceneFlowController.pending_gauntlet_run if SceneFlowController else null
	var elapsed := run.get_elapsed_ms() if run else 0
	var launch := _get_current_launch()
	if not victory:
		if run and launch:
			AnalyticsService.track_event(
				"gauntlet_failed",
				{"total_ms": elapsed, "labour_index": launch.gauntlet_labour_index}
			)
		_show_gauntlet_final(false, elapsed)
		return
	if launch and launch.gauntlet_labour_index >= GauntletRunState.GAUNTLET_LEVEL_IDS.size() - 1:
		if run:
			run.record_labour_clear(elapsed)
		_show_gauntlet_final(true, elapsed)
		return
	_chain_next_gauntlet_labour(elapsed)


func _chain_next_gauntlet_labour(elapsed_ms: int) -> void:
	var launch := _get_current_launch()
	var cleared_num := launch.gauntlet_labour_index + 1 if launch else 1
	if _gauntlet_chain_overlay:
		_gauntlet_chain_overlay.visible = true
	if _gauntlet_chain_label:
		_gauntlet_chain_label.text = (
			"Labour %d cleared — %s"
			% [cleared_num, GauntletGhostController.format_time_ms(elapsed_ms)]
		)
	if _results_panel:
		_results_panel.visible = false
	get_tree().create_timer(1.5).timeout.connect(func() -> void:
		if _gauntlet_chain_overlay:
			_gauntlet_chain_overlay.visible = false
		if SceneFlowController:
			SceneFlowController.advance_gauntlet_after_victory(elapsed_ms)
		_gauntlet_handling = false
	, CONNECT_ONE_SHOT)


func _show_gauntlet_final(victory: bool, elapsed_ms: int) -> void:
	var run := SceneFlowController.pending_gauntlet_run if SceneFlowController else null
	var improved := false
	if victory and run and SaveSystem:
		improved = SaveSystem.try_set_gauntlet_best(run)
		AnalyticsService.gauntlet_completed(elapsed_ms)
		if improved:
			AnalyticsService.gauntlet_pb_beaten(elapsed_ms)
	if SceneFlowController:
		SceneFlowController.clear_gauntlet_run()
	if _results_panel:
		_results_panel.visible = true
	if _results_title_label:
		_results_title_label.text = "Gauntlet Complete!" if victory else "Gauntlet Failed"
	if _results_reason_label:
		if victory:
			var pb := SaveSystem.get_gauntlet_best() if SaveSystem else {}
			var extra := "New personal best!" if improved else ""
			if not improved and int(pb.get("total_ms", 0)) > 0:
				var delta := GauntletGhostController.delta_vs_pb(elapsed_ms, pb)
				extra = "%s vs PB" % GauntletGhostController.format_delta_sec(delta)
			_results_reason_label.text = "%s\n%s" % [
				GauntletGhostController.format_time_ms(elapsed_ms),
				extra,
			]
		else:
			_results_reason_label.text = "Stopped at %s" % GauntletGhostController.format_time_ms(elapsed_ms)
	if _results_rewards_label:
		_results_rewards_label.text = ""
		_results_rewards_label.visible = false
	if _results_summary_label:
		_results_summary_label.text = ""
	if _replay_btn:
		_replay_btn.visible = false
	if _map_btn:
		_map_btn.visible = true
	_gauntlet_handling = false
