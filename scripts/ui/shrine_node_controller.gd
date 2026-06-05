class_name ShrineNodeController
extends Control

signal boon_chosen(card_id: String)
signal cancelled

var _grid: GridContainer = null


func _ready() -> void:
	visible = false
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.04, 0.06, 0.12, 0.85)
	add_child(backdrop)
	var panel := Panel.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -360.0
	panel.offset_top = -200.0
	panel.offset_right = 360.0
	panel.offset_bottom = 200.0
	add_child(panel)
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 16.0
	root.offset_top = 16.0
	root.offset_right = -16.0
	root.offset_bottom = -16.0
	root.add_child(root)
	var title := Label.new()
	title.text = "Shrine — choose a Fate boon"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(title)
	_grid = GridContainer.new()
	_grid.columns = 1
	_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(_grid)
	var cancel_btn := Button.new()
	cancel_btn.text = "Back"
	cancel_btn.pressed.connect(func() -> void:
		visible = false
		cancelled.emit()
	)
	root.add_child(cancel_btn)


func show_shrine_pick() -> void:
	for child in _grid.get_children():
		child.free()
	var pool: Array[FateCardData] = ContentRegistry.get_all_fate_cards() if ContentRegistry else []
	var shuffled := pool.duplicate()
	shuffled.shuffle()
	for i in range(mini(3, shuffled.size())):
		var card: FateCardData = shuffled[i]
		var btn := Button.new()
		btn.text = "%s — %s" % [card.title, card.description]
		btn.pressed.connect(func() -> void:
			visible = false
			boon_chosen.emit(card.card_id)
		)
		_grid.add_child(btn)
	visible = true
