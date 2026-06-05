class_name BattleHudController
extends CanvasLayer
var context: BattleContext = null
var _fate_draft: FateDraftController = null
var _tower_spot_panel: TowerSpotPanelController = null
var _tower_drag: TowerBuildDragController = null
var _last_victory: bool = false
var _tutorial_gating: bool = false
var _last_tutorial_allowed: PackedStringArray = PackedStringArray()
@onready var _gold_label: Label = %GoldLabel
@onready var _sf_label: Label = %SacredFireLabel
@onready var _lives_label: Label = %LivesLabel
@onready var _wave_label: Label = %WaveLabel
@onready var _morale_label: Label = %MoraleLabel
@onready var _alert_label: Label = %AlertLabel
@onready var _cleanse_hint: Label = %CleanseHintLabel
@onready var _start_btn: Button = %StartWaveButton
@onready var _pause_btn: Button = %PauseButton
@onready var _speed_btn: Button = %SpeedButton
@onready var _cleanse_btn: Button = %CleanseButton
@onready var _skill_btn: Button = %SkillButton
@onready var _forge_btn: Button = %ForgeButton
@onready var _replay_btn: Button = %ReplayButton
@onready var _map_btn: Button = %MapButton
@onready var _results_panel: Panel = %ResultsPanel
@onready var _results_label: Label = %ResultsLabel
@onready var _pardeh_panel: Panel = %PardehPanel
@onready var _tower_buttons: HBoxContainer = %TowerButtons
@onready var _minimap: MinimapController = %MinimapPanel
@onready var _threat_indicator: ThreatIndicatorController = %ThreatIndicators
var _tower_button_group: ButtonGroup = null
var _forge_wired: bool = false
func initialize(ctx: BattleContext, fate_draft: FateDraftController) -> void:
	context = ctx
	_fate_draft = fate_draft
	_tower_spot_panel = get_node_or_null("%TowerSpotPanel") as TowerSpotPanelController
	if _tower_spot_panel:
		_tower_spot_panel.initialize(ctx)
	if ctx.tower_manager:
		ctx.tower_manager.tower_spot_opened.connect(_on_tower_spot_opened)
	if ctx.bridge:
		ctx.bridge.gold_changed.connect(_on_gold)
		ctx.bridge.sacred_fire_changed.connect(_on_sf)
		ctx.bridge.lives_changed.connect(_on_lives)
		ctx.bridge.wave_changed.connect(_on_wave)
		ctx.bridge.alert_message.connect(_on_alert)
		ctx.bridge.battle_state_changed.connect(_on_state)
		ctx.bridge.pardeh_break_requested.connect(_on_pardeh)
		ctx.bridge.results_requested.connect(_on_results)
		ctx.bridge.morale_changed.connect(_on_morale)
		ctx.bridge.run_summary_ready.connect(_on_run_summary)
		ctx.bridge.region_selected.connect(_on_region_selected)
		ctx.bridge.region_light_changed.connect(_on_region_light_changed)
	_on_gold(ctx.economy.gold if ctx.economy else 0)
	_on_sf(ctx.economy.sacred_fire if ctx.economy else 0)
	_on_lives(ctx.lives.current_lives if ctx.lives else 0, ctx.lives.max_lives if ctx.lives else 0)
	_refresh_cleanse_hint()
	_setup_tower_drag()
	_setup_tower_buttons()
	setup_ancestral_forge(ctx)
	if _results_panel:
		_results_panel.visible = false
	if _pardeh_panel:
		_pardeh_panel.visible = false
	if _replay_btn:
		_replay_btn.visible = false
	if _map_btn:
		_map_btn.visible = false
func _ready() -> void:
	if _start_btn:
		_start_btn.pressed.connect(_on_start)
	if _pause_btn:
		_pause_btn.pressed.connect(_on_pause)
	if _speed_btn:
		_speed_btn.pressed.connect(_on_speed)
	if _cleanse_btn:
		_cleanse_btn.pressed.connect(_on_cleanse)
	if _skill_btn:
		_skill_btn.pressed.connect(_on_skill)
	if _replay_btn:
		_replay_btn.pressed.connect(_on_replay)
	if _map_btn:
		_map_btn.pressed.connect(_on_map)
func get_highlight_target(key: String) -> Control:
	match key:
		"tower_buttons":
			return _tower_buttons
		"start_wave":
			return _start_btn
		"skill":
			return _skill_btn
		"cleanse":
			return _cleanse_btn
		"gold":
			return _gold_label
		"sacred_fire":
			return _sf_label
		"lives":
			return _lives_label
		"pause":
			return _pause_btn
		"speed":
			return _speed_btn
		"pause_speed":
			return _pause_btn
		"forge":
			return _forge_btn
		"fate_draft":
			return _pardeh_panel
	return null
func setup_ancestral_forge(ctx: BattleContext) -> void:
	if _forge_btn == null or _forge_wired:
		return
	_forge_wired = true
	_forge_btn.pressed.connect(_on_forge_pressed.bind(ctx))


func setup_camera_ui(camera: TouchCamera) -> void:
	if _minimap and camera:
		_minimap.initialize(context, camera)
	if _threat_indicator and camera:
		_threat_indicator.initialize(context, camera)
func _on_forge_pressed(ctx: BattleContext) -> void:
	if ctx and ctx.ancestral_forge and ctx.ancestral_forge.try_fuse_any_adjacent_pair():
		_on_alert("Adjacent towers fused!", 50)
	elif ctx and ctx.bridge:
		ctx.bridge.alert_message.emit("Place two adjacent towers to fuse", 45)
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
	_set_control_enabled(_skill_btn, allow.get("skill", false))
	_set_control_enabled(_forge_btn, false)
	_set_tower_buttons_enabled(allow.get("tower_buttons", false))
func clear_tutorial_gating() -> void:
	_tutorial_gating = false
	_last_tutorial_allowed = PackedStringArray()
	_set_control_enabled(_start_btn, true)
	_set_control_enabled(_pause_btn, true)
	_set_control_enabled(_speed_btn, true)
	_set_control_enabled(_cleanse_btn, true)
	_set_control_enabled(_skill_btn, true)
	if _forge_btn:
		_set_control_enabled(_forge_btn, true)
	_set_tower_buttons_enabled(true)
func _set_control_enabled(control: Control, enabled: bool) -> void:
	if control == null:
		return
	if control is BaseButton:
		(control as BaseButton).disabled = not enabled
	control.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE
func _set_tower_buttons_enabled(enabled: bool) -> void:
	if _tower_buttons == null:
		return
	_tower_buttons.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE
	for child in _tower_buttons.get_children():
		if child is BaseButton:
			(child as BaseButton).disabled = not enabled
func _setup_tower_drag() -> void:
	if _tower_drag != null:
		return
	_tower_drag = TowerBuildDragController.new()
	_tower_drag.name = "TowerBuildDragController"
	add_child(_tower_drag)
	if context:
		_tower_drag.initialize(context)
func refresh_skill_label() -> void:
	if _skill_btn == null or context == null or context.hero_manager == null:
		return
	var hero := context.hero_manager.hero
	if hero and hero.data:
		match hero.data.skill_id:
			"zal_foresight":
				_skill_btn.text = "Zal Foresight"
			_:
				_skill_btn.text = "Rostam Skill"
func _setup_tower_buttons() -> void:
	if _tower_buttons == null or context == null or context.level_data == null:
		return
	if _tower_button_group == null:
		_tower_button_group = ButtonGroup.new()
	for child in _tower_buttons.get_children():
		child.queue_free()
	for tid in context.level_data.available_tower_ids:
		var td := ContentRegistry.get_tower(tid)
		if td == null:
			continue
		var btn := Button.new()
		btn.text = "%s\n%dG" % [td.display_name, td.build_cost]
		btn.toggle_mode = true
		btn.button_group = _tower_button_group
		btn.pressed.connect(func() -> void:
			if context.tower_manager:
				context.tower_manager.selected_tower_id = tid
		)
		_tower_buttons.add_child(btn)
		if _tower_drag:
			_tower_drag.register_tower_button(btn, tid)
		if tid == "tower_archer":
			btn.button_pressed = true
	if _tutorial_gating:
		apply_tutorial_gating(_last_tutorial_allowed)
func _on_tower_spot_opened(spot: BuildSpot) -> void:
	if _tower_spot_panel:
		_tower_spot_panel.show_for_spot(spot)
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
			_cleanse_hint.text = "Cleanse: auto â†’ %s (%d)" % [auto, ml.get_light(auto)]
		else:
			_cleanse_hint.text = "Cleanse: auto"
func _on_start() -> void:
	if context and context.state_controller:
		context.state_controller.start_battle()
		if _start_btn:
			_start_btn.disabled = true
func _on_pause() -> void:
	if context == null or context.state_controller == null:
		return
	if context.state_controller.current_state == GameEnums.BattleState.PAUSED:
		context.state_controller.resume_battle()
	else:
		context.state_controller.pause_battle()
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
	if context and context.hero_manager and context.hero_manager.hero:
		context.hero_manager.hero.use_skill()
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
			if _results_label:
				_results_label.text += "\n\nRoguelite run ended."
			SceneFlowController.go_to_world_map()
		return
	if launch and launch.is_endless_mode and not _last_victory and context and context.wave_manager:
		SaveSystem.set_endless_best(context.wave_manager.get_endless_wave_count())
	SceneFlowController.go_to_world_map()
func _on_gold(v: int) -> void:
	if _gold_label:
		_gold_label.text = "Gold: %d" % v
func _on_sf(v: int) -> void:
	if _sf_label:
		_sf_label.text = "Sacred Fire: %d" % v
func _on_lives(c: int, m: int) -> void:
	if _lives_label:
		_lives_label.text = "Lives: %d/%d" % [c, m]
func _on_wave(c: int, t: int) -> void:
	if _wave_label:
		_wave_label.text = "Wave: %d/%d" % [c, t]
func _on_morale(current: int, max_m: int) -> void:
	if _morale_label:
		_morale_label.text = "Morale: %d/%d" % [current, max_m]
func _on_run_summary(summary: Dictionary) -> void:
	if _results_label and summary:
		var extra := "\nFate: %s | Morale: %s" % [
			summary.get("fate_card", ""),
			summary.get("morale", 0),
		]
		if bool(summary.get("objective_done", false)):
			extra += " | Objective complete"
		elif context and context.objectives and context.objectives.failed:
			extra += " | Objective failed"
		_results_label.text += extra
func _on_alert(msg: String, _prio: int) -> void:
	if _alert_label:
		_alert_label.text = msg
func _on_state(state: GameEnums.BattleState) -> void:
	if state == GameEnums.BattleState.PRE_BATTLE and _start_btn and not _tutorial_gating:
		_start_btn.disabled = false
	elif state == GameEnums.BattleState.PRE_BATTLE and _tutorial_gating:
		apply_tutorial_gating(_last_tutorial_allowed)
	if _tower_spot_panel and _tower_spot_panel.visible:
		_tower_spot_panel.refresh_panel()
func _on_pardeh() -> void:
	if _fate_draft:
		_fate_draft.show_draft()
	if _pardeh_panel:
		_pardeh_panel.visible = true
	if _tower_spot_panel:
		_tower_spot_panel.hide_panel()
func _on_results(victory: bool, reason: String) -> void:
	_last_victory = victory
	if _tower_spot_panel:
		_tower_spot_panel.hide_panel()
	if _results_panel:
		_results_panel.visible = true
	var is_tutorial := context and context.level_data and context.level_data.is_tutorial
	if _results_label:
		var msg := "Victory!" if victory else "Defeat"
		_results_label.text = "%s\n(%s)" % [msg, reason]
		if victory and context and context.economy:
			var earned := context.economy.forge_materials_earned
			if not earned.is_empty():
				var lines: PackedStringArray = PackedStringArray()
				lines.append("Star Iron earned:")
				for mat_id in earned.keys():
					var mat_name := ForgeService.get_material_name(str(mat_id)) if ForgeService else str(mat_id)
					lines.append("  %s +%d" % [mat_name, int(earned[mat_id])])
				_results_label.text += "\n\n" + "\n".join(lines)
	if _replay_btn:
		_replay_btn.visible = true
		_replay_btn.text = "Continue" if is_tutorial else "Replay"
	if _map_btn:
		_map_btn.visible = not is_tutorial
