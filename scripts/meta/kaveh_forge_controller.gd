extends Control

@onready var _tower_list: VBoxContainer = %TowerList
@onready var _back_btn: Button = %BackButton
@onready var _summary_label: Label = %SummaryLabel
@onready var _scroll: ScrollContainer = $Scroll

var _tabs: TabContainer = null
var _spell_list: VBoxContainer = null
var _store_list: VBoxContainer = null


func _ready() -> void:
	if _back_btn:
		_back_btn.pressed.connect(_on_back)
	_setup_tabs()
	_refresh()


func _setup_tabs() -> void:
	if _scroll == null:
		return
	var parent := _scroll.get_parent()
	if parent == null:
		return
	_tabs = TabContainer.new()
	_tabs.name = "ForgeTabs"
	_tabs.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_tabs.offset_left = 80.0
	_tabs.offset_top = 130.0
	_tabs.offset_right = -80.0
	_tabs.offset_bottom = -70.0
	parent.add_child(_tabs)
	parent.move_child(_tabs, _scroll.get_index())
	_scroll.visible = false

	var towers_tab := ScrollContainer.new()
	towers_tab.name = "Towers"
	_tower_list.get_parent().remove_child(_tower_list)
	towers_tab.add_child(_tower_list)
	_tabs.add_child(towers_tab)

	var spells_tab := ScrollContainer.new()
	spells_tab.name = "Spells"
	_spell_list = VBoxContainer.new()
	_spell_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_spell_list.add_theme_constant_override("separation", 12)
	spells_tab.add_child(_spell_list)
	_tabs.add_child(spells_tab)

	var store_tab := ScrollContainer.new()
	store_tab.name = "Store"
	_store_list = VBoxContainer.new()
	_store_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_store_list.add_theme_constant_override("separation", 12)
	store_tab.add_child(_store_list)
	_tabs.add_child(store_tab)


func _refresh() -> void:
	_refresh_towers()
	_refresh_spells()
	_refresh_store()


func _refresh_towers() -> void:
	if _tower_list == null:
		return
	for child in _tower_list.get_children():
		child.queue_free()
	if ForgeService == null:
		return
	if _summary_label:
		var elite_count := ForgeService.count_elite_towers()
		var need := ForgeService.REQUIRED_ELITE_FOR_DAMAVAND
		var tokens := SaveSystem.get_forge_tokens() if SaveSystem else 0
		var horde := SaveSystem.get_horde_clears_count() if SaveSystem else 0
		_summary_label.text = (
			"Forge Tokens: %d | Horde: %d/8 | Elite towers: %d / %d (Damavand needs %d)"
			% [tokens, horde, elite_count, ForgeService.get_all_forgeable_tower_ids().size(), need]
		)
	for tower_id in ForgeService.get_locked_unlockable_tower_ids():
		_tower_list.add_child(_build_unlock_row(tower_id))
	for tower_id in ForgeService.get_all_forgeable_tower_ids():
		if SaveSystem and not SaveSystem.is_tower_in_pool(tower_id):
			continue
		_tower_list.add_child(_build_tower_row(tower_id))


func _refresh_spells() -> void:
	if _spell_list == null or ContentRegistry == null:
		return
	for child in _spell_list.get_children():
		child.queue_free()
	for spell in ContentRegistry.get_all_spells():
		_spell_list.add_child(_build_spell_row(spell))


func _refresh_store() -> void:
	if _store_list == null or StoreService == null:
		return
	for child in _store_list.get_children():
		child.queue_free()
	for product_id in StoreService.get_product_ids():
		_store_list.add_child(_build_store_row(product_id))


func _build_unlock_row(tower_id: String) -> PanelContainer:
	var td := ForgeService.get_tower_data(tower_id)
	var panel := PanelContainer.new()
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	panel.add_child(row)
	var info := VBoxContainer.new()
	info.custom_minimum_size = Vector2(320, 0)
	var title := Label.new()
	title.text = "%s (Locked)" % (td.display_name if td else tower_id)
	title.add_theme_font_size_override("font_size", 18)
	info.add_child(title)
	var mat_id := ForgeService.get_material_id_for_tower(tower_id)
	var mat_name := td.forge_material_name if td else mat_id
	var balance := SaveSystem.get_material(mat_id) if SaveSystem else 0
	var cost := ForgeService.get_unlock_cost(tower_id)
	var status := Label.new()
	status.text = "Unlock: %d %s (you have %d)" % [cost, mat_name, balance]
	info.add_child(status)
	row.add_child(info)
	var unlock_btn := Button.new()
	unlock_btn.text = "Unlock tower"
	unlock_btn.disabled = not ForgeService.can_unlock_tower(tower_id)
	unlock_btn.pressed.connect(func() -> void:
		if ForgeService.unlock_tower_to_pool(tower_id):
			_refresh()
	)
	row.add_child(unlock_btn)
	return panel


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


func _build_spell_row(spell: SpellData) -> PanelContainer:
	var panel := PanelContainer.new()
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	panel.add_child(row)

	var info := VBoxContainer.new()
	info.custom_minimum_size = Vector2(360, 0)
	var title := Label.new()
	title.text = "%s (%s)" % [spell.display_name, spell.rarity_label()]
	title.add_theme_font_size_override("font_size", 16)
	info.add_child(title)
	var desc := Label.new()
	desc.text = spell.description
	info.add_child(desc)
	row.add_child(info)

	var owned := SaveSystem and SaveSystem.owns_spell(spell.spell_id)
	var actions := VBoxContainer.new()
	if owned:
		var owned_label := Label.new()
		owned_label.text = "Owned"
		actions.add_child(owned_label)
	else:
		var token_btn := Button.new()
		token_btn.text = "Buy (%d Tokens)" % spell.forge_token_cost
		token_btn.disabled = SaveSystem == null or SaveSystem.get_forge_tokens() < spell.forge_token_cost
		token_btn.pressed.connect(func() -> void:
			if StoreService and StoreService.buy_spell_with_tokens(spell.spell_id):
				_refresh()
		)
		actions.add_child(token_btn)
		if spell.store_product_id != "" and StoreService:
			var money_btn := Button.new()
			var product := StoreService.get_product(spell.store_product_id)
			money_btn.text = "Buy (%s)" % product.get("price_label", "$")
			money_btn.pressed.connect(func() -> void:
				if StoreService.purchase(spell.store_product_id):
					_refresh()
			)
			actions.add_child(money_btn)
	row.add_child(actions)
	return panel


func _build_store_row(product_id: String) -> PanelContainer:
	var product := StoreService.get_product(product_id)
	var panel := PanelContainer.new()
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	panel.add_child(row)

	var info := Label.new()
	info.custom_minimum_size = Vector2(360, 0)
	info.text = "%s — %s" % [product.get("display_name", product_id), product.get("price_label", "")]
	row.add_child(info)

	var buy_btn := Button.new()
	var owned := StoreService.owns_product(product_id)
	buy_btn.text = "Owned" if owned else "Purchase (stub IAP)"
	buy_btn.disabled = owned
	buy_btn.pressed.connect(func() -> void:
		if StoreService.purchase(product_id):
			_refresh()
	)
	row.add_child(buy_btn)
	return panel


func _on_back() -> void:
	if SceneFlowController == null:
		return
	if SceneFlowController.forge_return_path == SceneFlowController.WORLD_MAP:
		SceneFlowController.go_to_world_map()
	else:
		SceneFlowController.go_to_main_menu()


func _on_elite_forged() -> void:
	if ForgeService == null or not ForgeService.can_enter_damavand():
		return
	if SaveSystem and not SaveSystem.is_damavand_forge_notified():
		SaveSystem.set_damavand_forge_notified()
		if SceneFlowController:
			SceneFlowController.pending_alert = "Elite tower forged — Hunt for Zahhak is now available!"
