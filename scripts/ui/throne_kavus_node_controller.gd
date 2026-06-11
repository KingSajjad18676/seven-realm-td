class_name ThroneKavusNodeController
extends Control

signal accepted
signal declined
signal cancelled

var _content_root: VBoxContainer = null


func _ready() -> void:
	visible = false
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.08, 0.04, 0.02, 0.88)
	add_child(backdrop)
	var panel := Panel.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -380.0
	panel.offset_top = -220.0
	panel.offset_right = 380.0
	panel.offset_bottom = 220.0
	add_child(panel)
	_content_root = VBoxContainer.new()
	_content_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_content_root.offset_left = 20.0
	_content_root.offset_top = 16.0
	_content_root.offset_right = -20.0
	_content_root.offset_bottom = -16.0
	_content_root.add_theme_constant_override("separation", 12)
	panel.add_child(_content_root)
	_build_static_ui()


func _build_static_ui() -> void:
	if _content_root == null:
		return
	var title := Label.new()
	title.text = "The Throne of Kavus"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	_content_root.add_child(title)
	var desc := Label.new()
	desc.text = (
		"King Kay Kavus offers to aid you from his flying throne.\n"
		+ "If you accept, his chariot will bombard the battlefield every 20 seconds - "
		+ "massive damage to enemies and your towers alike."
	)
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_content_root.add_child(desc)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	var accept_btn := Button.new()
	accept_btn.text = "Accept the King's Help"
	accept_btn.pressed.connect(_on_accept)
	row.add_child(accept_btn)
	var decline_btn := Button.new()
	decline_btn.text = "Decline"
	decline_btn.pressed.connect(_on_decline)
	row.add_child(decline_btn)
	_content_root.add_child(row)
	var back_btn := Button.new()
	back_btn.text = "Back"
	back_btn.pressed.connect(_on_back)
	_content_root.add_child(back_btn)


func show_offer() -> void:
	visible = true


func _on_accept() -> void:
	visible = false
	accepted.emit()


func _on_decline() -> void:
	visible = false
	declined.emit()


func _on_back() -> void:
	visible = false
	cancelled.emit()
