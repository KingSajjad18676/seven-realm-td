class_name RelicSlotPickerController
extends Control

signal relic_slotted(tower_id: String, relic_id: String)
signal cancelled

var _tower_ids: Array[String] = []
var _slots: Dictionary = {}
var _pending_relic: RelicData = null
var _grid: GridContainer = null
var _replace_panel: Panel = null
var _replace_label: Label = null
var _title_label: Label = null


func _ready() -> void:
	visible = false
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.03, 0.05, 0.1, 0.88)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(backdrop)
	var panel := Panel.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -380.0
	panel.offset_top = -240.0
	panel.offset_right = 380.0
	panel.offset_bottom = 240.0
	add_child(panel)
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 16.0
	root.offset_top = 16.0
	root.offset_right = -16.0
	root.offset_bottom = -16.0
	root.add_theme_constant_override("separation", 10)
	panel.add_child(root)
	var title := Label.new()
	title.name = "TitleLabel"
	title.text = "Relics of the Shahs"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	root.add_child(title)
	_title_label = title
	var hint := Label.new()
	hint.text = "Choose a crown or ring to slot into a tower type for this run."
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(hint)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 220)
	root.add_child(scroll)
	_grid = GridContainer.new()
	_grid.columns = 1
	_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_grid.add_theme_constant_override("v_separation", 8)
	scroll.add_child(_grid)
	var cancel_btn := Button.new()
	cancel_btn.text = "Back"
	cancel_btn.pressed.connect(_on_cancel)
	root.add_child(cancel_btn)
	_build_replace_panel()


func _build_replace_panel() -> void:
	_replace_panel = Panel.new()
	_replace_panel.visible = false
	_replace_panel.set_anchors_preset(Control.PRESET_CENTER)
	_replace_panel.offset_left = -260.0
	_replace_panel.offset_top = -90.0
	_replace_panel.offset_right = 260.0
	_replace_panel.offset_bottom = 90.0
	add_child(_replace_panel)
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 12.0
	root.offset_top = 12.0
	root.offset_right = -12.0
	root.offset_bottom = -12.0
	root.add_theme_constant_override("separation", 10)
	_replace_panel.add_child(root)
	_replace_label = Label.new()
	_replace_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_replace_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(_replace_label)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	var confirm := Button.new()
	confirm.text = "Replace"
	confirm.pressed.connect(_confirm_replace)
	row.add_child(confirm)
	var keep := Button.new()
	keep.text = "Keep current"
	keep.pressed.connect(_cancel_replace)
	row.add_child(keep)
	root.add_child(row)


func show_pick(
	tower_ids: Array[String],
	slots: Dictionary,
	title_text: String = "Relics of the Shahs"
) -> void:
	_tower_ids = tower_ids.duplicate()
	_slots = slots.duplicate()
	_pending_relic = null
	_replace_panel.visible = false
	if _title_label:
		_title_label.text = title_text
	for child in _grid.get_children():
		child.free()
	var picks := RelicSlotHelper.pick_relic_pool(_tower_ids, _slots, 3)
	if picks.is_empty():
		cancelled.emit()
		visible = false
		return
	for relic in picks:
		var td := ContentRegistry.get_tower(relic.slot_tower_id) if ContentRegistry else null
		var tower_name := td.display_name if td else relic.slot_tower_id
		var btn := Button.new()
		btn.text = "%s\n(%s) — %s" % [relic.title, tower_name, relic.description]
		btn.pressed.connect(_on_relic_pressed.bind(relic))
		_grid.add_child(btn)
	visible = true


func _on_relic_pressed(relic: RelicData) -> void:
	if relic == null:
		return
	var tower_id := relic.slot_tower_id
	var existing := str(_slots.get(tower_id, ""))
	if existing != "" and existing != relic.relic_id:
		_pending_relic = relic
		var old := ContentRegistry.get_relic(existing) if ContentRegistry else null
		var old_title := old.title if old else existing
		_replace_label.text = "Replace %s with %s on %s?" % [
			old_title,
			relic.title,
			_get_tower_name(tower_id),
		]
		_replace_panel.visible = true
		return
	_commit_slot(tower_id, relic.relic_id)


func _confirm_replace() -> void:
	if _pending_relic == null:
		return
	_commit_slot(_pending_relic.slot_tower_id, _pending_relic.relic_id)
	_pending_relic = null
	_replace_panel.visible = false


func _cancel_replace() -> void:
	_pending_relic = null
	_replace_panel.visible = false


func _commit_slot(tower_id: String, relic_id: String) -> void:
	_slots = RelicSlotHelper.apply_slot(_slots, tower_id, relic_id)
	visible = false
	_replace_panel.visible = false
	relic_slotted.emit(tower_id, relic_id)


func _on_cancel() -> void:
	visible = false
	_replace_panel.visible = false
	cancelled.emit()


func _get_tower_name(tower_id: String) -> String:
	var td := ContentRegistry.get_tower(tower_id) if ContentRegistry else null
	return td.display_name if td else tower_id
