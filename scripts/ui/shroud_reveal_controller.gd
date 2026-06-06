class_name ShroudRevealController
extends Control

signal reveal_confirmed(node_id: String)
signal cancelled

var _body_label: Label = null
var _pending_node_id: String = ""


func _ready() -> void:
	visible = false
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.02, 0.03, 0.06, 0.88)
	add_child(backdrop)
	var panel := Panel.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -300.0
	panel.offset_top = -120.0
	panel.offset_right = 300.0
	panel.offset_bottom = 120.0
	add_child(panel)
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 16.0
	root.offset_top = 16.0
	root.offset_right = -16.0
	root.offset_bottom = -16.0
	root.add_theme_constant_override("separation", 12)
	panel.add_child(root)
	var title := Label.new()
	title.text = "Ahriman's Shroud"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	root.add_child(title)
	_body_label = Label.new()
	_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(_body_label)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	var confirm_btn := Button.new()
	confirm_btn.text = "Reveal path"
	confirm_btn.pressed.connect(_on_confirm)
	row.add_child(confirm_btn)
	var cancel_btn := Button.new()
	cancel_btn.text = "Cancel"
	cancel_btn.pressed.connect(_on_cancel)
	row.add_child(cancel_btn)
	root.add_child(row)


func show_reveal_offer(node_id: String, cost: int, run_sf: int) -> void:
	_pending_node_id = node_id
	_body_label.text = (
		"Spend %d Sacred Fire to reveal this node's identity?\n"
		+ "Run Sacred Fire: %d"
		% [cost, run_sf]
	)
	visible = true


func _on_confirm() -> void:
	var node_id := _pending_node_id
	_pending_node_id = ""
	visible = false
	if node_id != "":
		reveal_confirmed.emit(node_id)


func _on_cancel() -> void:
	_pending_node_id = ""
	visible = false
	cancelled.emit()
