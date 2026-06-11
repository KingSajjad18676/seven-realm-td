class_name EquipmentScreenController
extends Control

## Equipment loadout screen — 4 slots + owned collection + hero skill picker.

var _panel: Panel = null
var _slot_labels: Dictionary = {}
var _owned_list: ItemList = null
var _skill_list: ItemList = null
var _set_info: Label = null


func open(parent: Control) -> void:
	if _panel != null:
		_panel.visible = true
		_refresh()
		return
	_build_ui(parent)
	_refresh()


func close() -> void:
	if _panel:
		_panel.visible = false


func _build_ui(parent: Control) -> void:
	_panel = Panel.new()
	_panel.name = "EquipmentScreen"
	_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_panel.offset_top = 80.0
	_panel.offset_bottom = -100.0
	parent.add_child(_panel)

	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 24.0
	root.offset_top = 16.0
	root.offset_right = -24.0
	root.offset_bottom = -16.0
	_panel.add_child(root)

	var title := Label.new()
	title.text = "Haft-Khan Loadout"
	root.add_child(title)

	var slots := HBoxContainer.new()
	root.add_child(slots)
	for slot_key in ["weapon", "armor", "helm", "talisman"]:
		var col := VBoxContainer.new()
		var slot_title := Label.new()
		slot_title.text = slot_key.capitalize()
		col.add_child(slot_title)
		var lbl := Label.new()
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		col.add_child(lbl)
		_slot_labels[slot_key] = lbl
		slots.add_child(col)

	var skill_title := Label.new()
	skill_title.text = "Hero Skill (before battle)"
	root.add_child(skill_title)

	_skill_list = ItemList.new()
	_skill_list.custom_minimum_size = Vector2(0, 96)
	_skill_list.item_selected.connect(_on_skill_selected)
	root.add_child(_skill_list)

	_set_info = Label.new()
	_set_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_set_info)

	_owned_list = ItemList.new()
	_owned_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_owned_list.item_selected.connect(_on_owned_selected)
	root.add_child(_owned_list)

	var close_btn := Button.new()
	close_btn.text = "Close"
	close_btn.pressed.connect(close)
	root.add_child(close_btn)


func _refresh() -> void:
	if not EquipmentService or not ContentRegistry:
		return
	var equipped := EquipmentService.get_equipped_map()
	for slot_key in _slot_labels.keys():
		var pid := str(equipped.get(slot_key, ""))
		var piece := ContentRegistry.get_equipment_piece(pid) if pid != "" else null
		_slot_labels[slot_key].text = piece.display_name if piece else "(empty)"

	_refresh_skills()

	_owned_list.clear()
	for pid in EquipmentService.get_owned_piece_ids():
		var piece := ContentRegistry.get_equipment_piece(pid)
		if piece:
			_owned_list.add_item("%s — %s" % [piece.display_name, EquipmentPieceData.slot_key(piece.slot_type)])

	var tiers := EquipmentService.get_set_bonus_tiers()
	var lines: PackedStringArray = []
	for set_data in ContentRegistry.get_all_equipment_sets():
		var count: int = int(tiers.get(set_data.set_id, 0))
		if count <= 0:
			continue
		lines.append("%s (%d/4)" % [set_data.set_name, count])
		if count >= 2:
			lines.append("  2pc: %s" % set_data.two_piece_description)
		if count >= 3:
			lines.append("  3pc: %s" % set_data.three_piece_description)
		if count >= 4:
			lines.append("  4pc: %s" % set_data.four_piece_description)
	_set_info.text = "\n".join(lines)


func _refresh_skills() -> void:
	if _skill_list == null or SaveSystem == null:
		return
	_skill_list.clear()
	var selected := SaveSystem.get_hero_skill_selected()
	for entry in ContentCatalog.get_hero_skill_catalog():
		var skill_id := str(entry.get("skill_id", ""))
		var display_name := str(entry.get("display_name", skill_id))
		var unlocked := SaveSystem.is_hero_skill_unlocked(skill_id)
		var suffix := ""
		if not unlocked:
			var unlock_level := str(entry.get("unlock_level_id", ""))
			suffix = " (locked — clear %s)" % unlock_level if unlock_level != "" else " (locked)"
		var marker := " *" if skill_id == selected else ""
		_skill_list.add_item("%s%s%s" % [display_name, suffix, marker])
		var idx := _skill_list.item_count - 1
		if not unlocked:
			_skill_list.set_item_disabled(idx, true)
		elif skill_id == selected:
			_skill_list.select(idx)


func _on_skill_selected(index: int) -> void:
	if SaveSystem == null or _skill_list == null or index < 0:
		return
	var catalog := ContentCatalog.get_hero_skill_catalog()
	if index >= catalog.size():
		return
	var skill_id := str(catalog[index].get("skill_id", ""))
	if not SaveSystem.is_hero_skill_unlocked(skill_id):
		return
	SaveSystem.set_hero_skill_selected(skill_id)
	_refresh_skills()


func _on_owned_selected(index: int) -> void:
	if not EquipmentService or not ContentRegistry:
		return
	var owned := EquipmentService.get_owned_piece_ids()
	if index < 0 or index >= owned.size():
		return
	var pid := owned[index]
	var piece := ContentRegistry.get_equipment_piece(pid)
	if piece == null:
		return
	EquipmentService.equip_piece(pid)
	_refresh()
