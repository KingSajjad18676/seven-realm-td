class_name VowOfferController
extends Node

var context: BattleContext = null
var _panel: Control = null
var _content_root: VBoxContainer = null
var _pending_vow: ObjectiveData = null
var _block_start: int = 1
var _block_end: int = 10


func initialize(ctx: BattleContext, panel: Control) -> void:
	context = ctx
	_panel = panel
	if _panel:
		_panel.visible = false
		_content_root = _panel.get_node_or_null("ContentRoot") as VBoxContainer


func show_offer(vow_data: ObjectiveData, block_start: int, block_end: int) -> void:
	if _panel == null or context == null or vow_data == null:
		return
	_pending_vow = vow_data
	_block_start = block_start
	_block_end = block_end
	_panel.visible = true
	if context.state_controller:
		context.state_controller.pause_battle()
	_build_ui(vow_data, block_start, block_end)


func _clear_content_root() -> void:
	if _content_root == null:
		return
	for child in _content_root.get_children():
		child.free()
	_content_root.add_theme_constant_override("separation", 10)


func _build_ui(vow_data: ObjectiveData, block_start: int, block_end: int) -> void:
	if _content_root == null:
		return
	_clear_content_root()
	var title := Label.new()
	title.text = "Hero's Vow — Peyman"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	_content_root.add_child(title)
	var desc := Label.new()
	desc.text = "%s\n%s\nWaves %d–%d" % [
		vow_data.title,
		vow_data.description,
		block_start,
		block_end,
	]
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_content_root.add_child(desc)
	var reward := Label.new()
	reward.text = "Honor: +%d SF, +%d morale  |  Break: -%d morale" % [
		vow_data.sacred_fire_reward,
		vow_data.morale_reward,
		vow_data.penalty_morale,
	]
	reward.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reward.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_content_root.add_child(reward)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	var accept_btn := Button.new()
	accept_btn.text = "Swear the Vow"
	accept_btn.pressed.connect(_on_accept)
	row.add_child(accept_btn)
	var decline_btn := Button.new()
	decline_btn.text = "Decline"
	decline_btn.pressed.connect(_on_decline)
	row.add_child(decline_btn)
	_content_root.add_child(row)


func _on_accept() -> void:
	if context and context.objectives and _pending_vow:
		context.objectives.activate_vow(_pending_vow, _block_start, _block_end)
	_finish()


func _on_decline() -> void:
	if context and context.objectives:
		context.objectives.decline_vow()
	if context and context.bridge:
		context.bridge.alert_message.emit("Vow declined", 40)
	_finish()


func _finish() -> void:
	_pending_vow = null
	if _panel:
		_panel.visible = false
		_clear_content_root()
	if context and context.state_controller:
		context.state_controller.resume_battle()
