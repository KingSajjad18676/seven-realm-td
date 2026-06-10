extends CanvasLayer

@onready var _panel: Panel = $Panel
@onready var _vbox: VBoxContainer = $Panel/VBox
@onready var _toggle_btn: Button = %ToggleButton
@onready var _actions_vbox: VBoxContainer = %ActionsVBox

var _expanded: bool = true


func _ready() -> void:
	add_to_group("debug_menu")
	visible = OS.is_debug_build()
	if _toggle_btn:
		_toggle_btn.pressed.connect(_toggle_expanded)
	_build_actions()
	_update_panel_size()


func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build() or not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F3:
		_toggle_expanded()
		get_viewport().set_input_as_handled()


func _toggle_expanded() -> void:
	_expanded = not _expanded
	if _actions_vbox:
		_actions_vbox.visible = _expanded
	if _toggle_btn:
		_toggle_btn.text = "Debug ▼" if _expanded else "Debug ▶"
	_update_panel_size()


func _build_actions() -> void:
	if _actions_vbox == null:
		return
	_register_action("Skip wave", _on_skip)
	_register_action("Force victory", _on_win)
	_register_action("Force defeat", _on_defeat)
	_register_action("Validate wave spawns", _on_validate_waves)
	_register_action("+100 gold", _on_gold)
	_register_action("+5 Sacred Fire", _on_add_sf)
	_register_action("Reset lives", _on_reset_lives)
	_register_action("Collapse north region", _on_collapse)


func _register_action(label: String, callback: Callable) -> void:
	var btn := Button.new()
	btn.text = label
	btn.pressed.connect(callback)
	_actions_vbox.add_child(btn)


func _update_panel_size() -> void:
	if _panel == null or _vbox == null:
		return
	await get_tree().process_frame
	var content_h := _vbox.get_combined_minimum_size().y + 16.0
	var content_w := maxf(_vbox.get_combined_minimum_size().x + 16.0, 120.0)
	_panel.offset_top = -content_h * 0.5
	_panel.offset_bottom = content_h * 0.5
	_panel.offset_right = _panel.offset_left + content_w


func _find_battle() -> BattleContext:
	var root := get_tree().get_first_node_in_group("battle_root")
	if root and root.has_node("BattleContextBridge"):
		var bridge := root.get_node("BattleContextBridge") as BattleContextBridge
		return bridge.context if bridge else null
	return null


func _on_skip() -> void:
	var ctx := _find_battle()
	if ctx and ctx.wave_manager:
		ctx.wave_manager.debug_force_wave_advance()


func _on_win() -> void:
	var ctx := _find_battle()
	if ctx and ctx.state_controller:
		ctx.state_controller.trigger_victory("debug")


func _on_defeat() -> void:
	var ctx := _find_battle()
	if ctx and ctx.state_controller:
		ctx.state_controller.trigger_defeat("debug")


func _on_validate_waves() -> void:
	var passed := WaveSpawnValidator.validate_and_report()
	var ctx := _find_battle()
	if ctx and ctx.bridge:
		var msg := "Wave spawn validation PASS" if passed else "Wave spawn validation FAIL — see console"
		ctx.bridge.alert_message.emit(msg, 120 if passed else 180)


func _on_gold() -> void:
	var ctx := _find_battle()
	if ctx and ctx.economy:
		ctx.economy.add_gold(100)


func _on_add_sf() -> void:
	var ctx := _find_battle()
	if ctx and ctx.economy:
		ctx.economy.add_sacred_fire(5)


func _on_reset_lives() -> void:
	var ctx := _find_battle()
	if ctx and ctx.lives:
		ctx.lives.current_lives = ctx.lives.max_lives
		ctx.lives._emit()


func _on_collapse() -> void:
	var ctx := _find_battle()
	if ctx and ctx.map_light:
		ctx.map_light.apply_corruption_pressure("region_north", 120.0)
