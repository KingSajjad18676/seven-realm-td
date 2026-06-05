extends Control

@onready var _tower_list: VBoxContainer = %TowerList
@onready var _back_btn: Button = %BackButton
@onready var _summary_label: Label = %SummaryLabel


func _ready() -> void:
	if _back_btn:
		_back_btn.pressed.connect(_on_back)
	_refresh()


func _refresh() -> void:
	if _tower_list == null:
		return
	for child in _tower_list.get_children():
		child.queue_free()
	if ForgeService == null:
		return
	if _summary_label:
		var elite_count := ForgeService.count_elite_towers()
		var need := ForgeService.REQUIRED_ELITE_FOR_DAMAVAND
		_summary_label.text = "Elite towers: %d / %d (Damavand requires %d)" % [
			elite_count, ForgeService.get_all_forgeable_tower_ids().size(), need
		]
	for tower_id in ForgeService.get_all_forgeable_tower_ids():
		_tower_list.add_child(_build_tower_row(tower_id))


func _build_tower_row(tower_id: String) -> PanelContainer:
	var td := ForgeService.get_tower_data(tower_id)
	var panel := PanelContainer.new()
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	panel.add_child(row)

	var info := VBoxContainer.new()
	info.custom_minimum_size = Vector2(320, 0)
	var title := Label.new()
	title.text = td.display_name if td else tower_id
	title.add_theme_font_size_override("font_size", 18)
	info.add_child(title)

	var mat_id := ForgeService.get_material_id_for_tower(tower_id)
	var mat_name := td.forge_material_name if td else mat_id
	var balance := SaveSystem.get_material(mat_id) if SaveSystem else 0
	var lvl := ForgeService.get_level(tower_id)
	var elite := ForgeService.get_elite_level(tower_id)
	var tier := ForgeService.get_visual_tier(tower_id)
	var status := Label.new()
	var status_text := "%s: %d | Lv %d/%d | Tier %d" % [
		mat_name, balance, lvl, ForgeService.NORMAL_MAX_LEVEL, tier
	]
	if ForgeService.is_elite(tower_id):
		status_text += " | ELITE"
	elif ForgeService.is_normal_maxed(tower_id):
		status_text += " | Elite %d/%d" % [elite, ForgeService.ELITE_MAX]
	status.text = status_text
	info.add_child(status)
	row.add_child(info)

	var actions := VBoxContainer.new()
	if not ForgeService.is_normal_maxed(tower_id):
		var forge_btn := Button.new()
		var cost := ForgeService.cost_for_next_level(tower_id)
		forge_btn.text = "Forge (%d %s)" % [cost, mat_name]
		forge_btn.disabled = not ForgeService.can_forge(tower_id)
		forge_btn.pressed.connect(func() -> void:
			if ForgeService.forge(tower_id):
				_refresh()
		)
		actions.add_child(forge_btn)
	elif not ForgeService.is_elite(tower_id):
		var elite_btn := Button.new()
		var e_cost := ForgeService.cost_for_next_elite(tower_id)
		elite_btn.text = "Forge Elite (%d %s)" % [e_cost, mat_name]
		elite_btn.disabled = not ForgeService.can_forge_elite(tower_id)
		elite_btn.pressed.connect(func() -> void:
			if ForgeService.forge_elite(tower_id):
				_on_elite_forged()
				_refresh()
		)
		actions.add_child(elite_btn)
	else:
		var done := Label.new()
		done.text = "Elite complete"
		actions.add_child(done)
	row.add_child(actions)
	return panel


func _on_back() -> void:
	SceneFlowController.go_to_main_menu()


func _on_elite_forged() -> void:
	if ForgeService == null or not ForgeService.can_enter_damavand():
		return
	if SaveSystem and not SaveSystem.is_damavand_forge_notified():
		SaveSystem.set_damavand_forge_notified()
		if SceneFlowController:
			SceneFlowController.pending_alert = "Elite tower forged — Hunt for Zahhak is now available!"
