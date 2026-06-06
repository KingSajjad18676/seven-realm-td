class_name CoopHeroPickerController
extends Control

signal confirmed(player_heroes: Array[String])
signal cancelled

var _panel: Panel = null
var _p1_pick: String = ""
var _p2_pick: String = ""
var _p1_buttons: Dictionary = {}
var _p2_buttons: Dictionary = {}


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_ui()
	hide()


func show_picker() -> void:
	_p1_pick = ""
	_p2_pick = ""
	_refresh_buttons()
	if _panel:
		_panel.visible = true
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP


func _build_ui() -> void:
	_panel = Panel.new()
	_panel.name = "CoopHeroPickerPanel"
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.offset_left = -260.0
	_panel.offset_top = -200.0
	_panel.offset_right = 260.0
	_panel.offset_bottom = 200.0
	add_child(_panel)

	var title := Label.new()
	title.text = "Brothers in Arms — Choose Heroes"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 12.0
	title.offset_bottom = 44.0
	_panel.add_child(title)

	var body := VBoxContainer.new()
	body.set_anchors_preset(Control.PRESET_FULL_RECT)
	body.offset_left = 20.0
	body.offset_top = 52.0
	body.offset_right = -20.0
	body.offset_bottom = -56.0
	body.add_theme_constant_override("separation", 12)
	_panel.add_child(body)

	body.add_child(_hero_row("Player 1", 0))
	body.add_child(_hero_row("Player 2", 1))

	var confirm := Button.new()
	confirm.text = "Confirm"
	confirm.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	confirm.offset_left = 80.0
	confirm.offset_top = -44.0
	confirm.offset_right = -80.0
	confirm.offset_bottom = -12.0
	confirm.pressed.connect(_on_confirm)
	_panel.add_child(confirm)


func _hero_row(label_text: String, player_index: int) -> VBoxContainer:
	var col := VBoxContainer.new()
	var label := Label.new()
	label.text = label_text
	col.add_child(label)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	for hero_id in CoopPlayerManager.BROTHERS_HERO_POOL:
		var hero := ContentRegistry.get_hero(hero_id)
		var btn := Button.new()
		btn.text = hero.display_name if hero else hero_id
		btn.pressed.connect(_on_hero_pressed.bind(player_index, hero_id))
		row.add_child(btn)
		if player_index == 0:
			_p1_buttons[hero_id] = btn
		else:
			_p2_buttons[hero_id] = btn
	col.add_child(row)
	return col


func _on_hero_pressed(player_index: int, hero_id: String) -> void:
	if player_index == 0:
		_p1_pick = hero_id
	else:
		_p2_pick = hero_id
	_refresh_buttons()


func _refresh_buttons() -> void:
	for hero_id in _p1_buttons.keys():
		var btn: Button = _p1_buttons[hero_id]
		btn.disabled = _p2_pick == hero_id
		btn.modulate = Color(0.7, 1.0, 0.7) if _p1_pick == hero_id else Color.WHITE
	for hero_id in _p2_buttons.keys():
		var btn: Button = _p2_buttons[hero_id]
		btn.disabled = _p1_pick == hero_id
		btn.modulate = Color(0.7, 0.85, 1.0) if _p2_pick == hero_id else Color.WHITE


func _on_confirm() -> void:
	if _p1_pick == "" or _p2_pick == "" or _p1_pick == _p2_pick:
		return
	if _panel:
		_panel.visible = false
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	confirmed.emit([_p1_pick, _p2_pick])
