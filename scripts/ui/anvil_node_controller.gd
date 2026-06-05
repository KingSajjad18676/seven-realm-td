class_name AnvilNodeController
extends Control

signal upgrade_chosen(tower_id: String)
signal cancelled

var _grid: GridContainer = null


func _ready() -> void:
	visible = false
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.05, 0.04, 0.02, 0.85)
	add_child(backdrop)
	var panel := Panel.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -300.0
	panel.offset_top = -180.0
	panel.offset_right = 300.0
	panel.offset_bottom = 180.0
	add_child(panel)
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 16.0
	root.offset_top = 16.0
	root.offset_right = -16.0
	root.offset_bottom = -16.0
	panel.add_child(root)
	var title := Label.new()
	title.text = "Anvil — upgrade one tower for this run"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(title)
	_grid = GridContainer.new()
	_grid.columns = 2
	_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(_grid)
	var cancel_btn := Button.new()
	cancel_btn.text = "Back"
	cancel_btn.pressed.connect(func() -> void:
		visible = false
		cancelled.emit()
	)
	root.add_child(cancel_btn)


func show_for_towers(tower_ids: Array[String]) -> void:
	for child in _grid.get_children():
		child.free()
	for tower_id in tower_ids:
		var td := ContentRegistry.get_tower(tower_id) if ContentRegistry else null
		var btn := Button.new()
		btn.text = "Upgrade %s (+1 run level)" % (td.display_name if td else tower_id)
		btn.pressed.connect(func() -> void:
			visible = false
			upgrade_chosen.emit(tower_id)
		)
		_grid.add_child(btn)
	visible = true
