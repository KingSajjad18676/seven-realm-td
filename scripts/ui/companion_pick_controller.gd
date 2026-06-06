class_name CompanionPickController
extends Control

signal companion_picked(companion_id: String)
signal skipped

var _grid: GridContainer = null
var _title_label: Label = null


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	var panel := Panel.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -380.0
	panel.offset_top = -280.0
	panel.offset_right = 380.0
	panel.offset_bottom = -20.0
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
	_title_label.text = "Choose a Companion"
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 20)
	root.add_child(_title_label)
	var hint := Label.new()
	hint.text = "One companion joins your Campaign Run (Royal Cheetah, Simurgh Fledgling, or Zavareh)."
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(hint)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 140)
	root.add_child(scroll)
	_grid = GridContainer.new()
	_grid.columns = 1
	_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_grid.add_theme_constant_override("v_separation", 8)
	scroll.add_child(_grid)
	var skip_btn := Button.new()
	skip_btn.text = "Decide later (relics only)"
	skip_btn.pressed.connect(_on_skip)
	root.add_child(skip_btn)


func show_pick(active_companion_id: String) -> void:
	for child in _grid.get_children():
		child.free()
	var picks := CompanionPickHelper.pick_pool(active_companion_id, 3)
	if picks.is_empty():
		visible = false
		skipped.emit()
		return
	for companion in picks:
		var btn := Button.new()
		btn.text = "%s — %s" % [companion.display_name, companion.description]
		btn.pressed.connect(_on_companion_pressed.bind(companion.companion_id))
		_grid.add_child(btn)
	visible = true


func _on_companion_pressed(companion_id: String) -> void:
	visible = false
	companion_picked.emit(companion_id)


func _on_skip() -> void:
	visible = false
	skipped.emit()
