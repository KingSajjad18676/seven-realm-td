class_name TowerDraftController
extends Control

signal draft_confirmed(tower_ids: Array[String])
signal draft_cancelled

const REQUIRED_START_COUNT := 3

var _pool: Array[String] = []
var _selected: Array[String] = []
var _pick_count: int = REQUIRED_START_COUNT
var _title_label: Label = null
var _status_label: Label = null
var _grid: GridContainer = null
var _confirm_btn: Button = null


func _ready() -> void:
	visible = false
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.02, 0.05, 0.08, 0.82)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(backdrop)
	var panel := Panel.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -360.0
	panel.offset_top = -220.0
	panel.offset_right = 360.0
	panel.offset_bottom = 220.0
	add_child(panel)
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 16.0
	root.offset_top = 16.0
	root.offset_right = -16.0
	root.offset_bottom = -16.0
	root.add_theme_constant_override("separation", 10)
	panel.add_child(root)
	_title_label = Label.new()
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 22)
	root.add_child(_title_label)
	_status_label = Label.new()
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(_status_label)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 240)
	root.add_child(scroll)
	_grid = GridContainer.new()
	_grid.columns = 2
	_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_grid.add_theme_constant_override("h_separation", 8)
	_grid.add_theme_constant_override("v_separation", 8)
	scroll.add_child(_grid)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	_confirm_btn = Button.new()
	_confirm_btn.text = "Confirm loadout"
	_confirm_btn.pressed.connect(_on_confirm)
	row.add_child(_confirm_btn)
	var cancel_btn := Button.new()
	cancel_btn.text = "Cancel"
	cancel_btn.pressed.connect(_on_cancel)
	row.add_child(cancel_btn)
	root.add_child(row)


func show_start_draft(pool: Array[String]) -> void:
	_pick_count = REQUIRED_START_COUNT
	_pool = pool.duplicate()
	_selected.clear()
	_title_label.text = "Draft your starting towers"
	_refresh()
	visible = true


func show_add_one_draft(pool: Array[String], exclude: Array[String]) -> void:
	_pick_count = 1
	_pool.clear()
	for tid in pool:
		if tid not in exclude:
			_pool.append(tid)
	_selected.clear()
	_title_label.text = "Add a tower to your run"
	_refresh()
	visible = true


func _refresh() -> void:
	for child in _grid.get_children():
		child.free()
	for tower_id in _pool:
		var td := ContentRegistry.get_tower(tower_id) if ContentRegistry else null
		var btn := Button.new()
		var picked := tower_id in _selected
		btn.text = "%s%s" % [td.display_name if td else tower_id, " ✓" if picked else ""]
		btn.toggle_mode = true
		btn.button_pressed = picked
		btn.pressed.connect(_on_toggle.bind(tower_id, btn))
		_grid.add_child(btn)
	_status_label.text = "Selected %d / %d" % [_selected.size(), _pick_count]
	_confirm_btn.disabled = _selected.size() != _pick_count


func _on_toggle(tower_id: String, btn: Button) -> void:
	if tower_id in _selected:
		_selected.erase(tower_id)
		btn.button_pressed = false
	elif _selected.size() < _pick_count:
		_selected.append(tower_id)
		btn.button_pressed = true
	else:
		btn.button_pressed = false
	_refresh()


func _on_confirm() -> void:
	if _selected.size() != _pick_count:
		return
	visible = false
	draft_confirmed.emit(_selected.duplicate())


func _on_cancel() -> void:
	visible = false
	draft_cancelled.emit()
