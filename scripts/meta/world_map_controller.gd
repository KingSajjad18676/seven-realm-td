extends Control

const KHAN_LEVELS: Array[Dictionary] = [
	{"id": "level_00_tutorial", "label": "Tutorial", "short": "T", "tutorial": true},
	{"id": "level_01", "label": "Labour 1", "short": "1"},
	{"id": "level_02", "label": "Labour 2", "short": "2"},
	{"id": "level_03", "label": "Labour 3", "short": "3"},
	{"id": "level_04", "label": "Labour 4", "short": "4"},
	{"id": "level_05", "label": "Labour 5", "short": "5"},
	{"id": "level_06", "label": "Labour 6", "short": "6"},
	{"id": "level_07", "label": "Labour 7", "short": "7"},
	{"id": "level_08_damavand", "label": "Damavand", "short": "D"},
]

@onready var _scroll: ScrollContainer = $ScrollContainer
@onready var _level_list: VBoxContainer = $ScrollContainer/LevelList
@onready var _node_row: HBoxContainer = $ScrollContainer/CampaignNodeRow
@onready var _back_btn: Button = $BackButton
@onready var _roguelite_btn: Button = %RogueliteButton
@onready var _endless_btn: Button = %EndlessButton
@onready var _horde_btn: Button = %HordeButton
@onready var _brothers_btn: Button = %BrothersButton
@onready var _throne_btn: Button = %ThroneButton
@onready var _hunt_btn: Button = %HuntButton
@onready var _gauntlet_btn: Button = %GauntletButton
@onready var _seals_label: Label = %SealsLabel
@onready var _forge_btn: Button = %ForgeLinkButton
@onready var _horde_picker: Panel = %HordePickerPanel
@onready var _horde_list: VBoxContainer = %HordeLevelList

var _run: CampaignRunState = null
var _campaign_panel: Panel = null
var _campaign_canvas: Control = null
var _campaign_desc: Label = null
var _tower_draft: TowerDraftController = null
var _anvil_ui: AnvilNodeController = null
var _shrine_ui: ShrineNodeController = null
var _throne_kavus_ui: ThroneKavusNodeController = null
var _shroud_reveal_ui: ShroudRevealController = null
var _pending_tower_pick_node_id: String = ""
var _coop_hero_picker: CoopHeroPickerController = null
var _brothers_picker: Panel = null
var _brothers_list: VBoxContainer = null
var _pending_brothers_heroes: Array[String] = []
var _pending_gauntlet_draft: bool = false
var _equipment_ui: EquipmentScreenController = null
var _daily_missions_ui: DailyMissionsPanelController = null


func _ready() -> void:
	if _level_list:
		_level_list.visible = false
	_setup_campaign_run_ui()
	_build_campaign_nodes()
	if _back_btn:
		_back_btn.pressed.connect(_on_back)
	if _roguelite_btn:
		_roguelite_btn.pressed.connect(_on_roguelite)
		_roguelite_btn.text = "Campaign Run"
	if _endless_btn:
		_endless_btn.pressed.connect(_on_endless)
	if _horde_btn:
		_horde_btn.pressed.connect(_on_horde_menu)
	if _brothers_btn:
		_brothers_btn.pressed.connect(_on_brothers_menu)
	if _throne_btn:
		_throne_btn.pressed.connect(_on_throne)
	if _hunt_btn:
		_hunt_btn.pressed.connect(_on_hunt)
	if _gauntlet_btn:
		_gauntlet_btn.pressed.connect(_on_gauntlet)
	if _forge_btn:
		_forge_btn.pressed.connect(_on_forge)
	_setup_meta_panels()
	_setup_brothers_ui()
	_refresh_mode_buttons()
	_show_pending_alert()
	_load_campaign_run()
	_process_pending_campaign_battle_result()
	if _run != null:
		_show_campaign_run_panel()


func _setup_campaign_run_ui() -> void:
	_campaign_panel = Panel.new()
	_campaign_panel.name = "CampaignRunPanel"
	_campaign_panel.visible = false
	_campaign_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_campaign_panel.offset_top = 90.0
	_campaign_panel.offset_bottom = -120.0
	add_child(_campaign_panel)
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 12.0
	root.offset_top = 8.0
	root.offset_right = -12.0
	root.offset_bottom = -8.0
	_campaign_panel.add_child(root)
	_campaign_desc = Label.new()
	_campaign_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_campaign_desc)
	var canvas_scroll := ScrollContainer.new()
	canvas_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(canvas_scroll)
	_campaign_canvas = Control.new()
	_campaign_canvas.custom_minimum_size = Vector2(900, 900)
	canvas_scroll.add_child(_campaign_canvas)
	var close_btn := Button.new()
	close_btn.text = "Hide run map (linear campaign below)"
	close_btn.pressed.connect(_hide_campaign_run_panel)
	root.add_child(close_btn)
	_tower_draft = TowerDraftController.new()
	_tower_draft.name = "TowerDraft"
	add_child(_tower_draft)
	_tower_draft.draft_confirmed.connect(_on_draft_confirmed)
	_tower_draft.draft_cancelled.connect(_on_draft_cancelled)
	_anvil_ui = AnvilNodeController.new()
	_anvil_ui.name = "AnvilNodeUI"
	add_child(_anvil_ui)
	_anvil_ui.upgrade_chosen.connect(_on_anvil_upgrade)
	_anvil_ui.cancelled.connect(_refresh_campaign_graph)
	_shrine_ui = ShrineNodeController.new()
	_shrine_ui.name = "ShrineNodeUI"
	add_child(_shrine_ui)
	_shrine_ui.relic_slotted.connect(_on_shrine_relic)
	_shrine_ui.companion_picked.connect(_on_shrine_companion)
	_shrine_ui.cancelled.connect(_refresh_campaign_graph)
	_throne_kavus_ui = ThroneKavusNodeController.new()
	_throne_kavus_ui.name = "ThroneKavusNodeUI"
	add_child(_throne_kavus_ui)
	_throne_kavus_ui.accepted.connect(_on_throne_kavus_accepted)
	_throne_kavus_ui.declined.connect(_on_throne_kavus_declined)
	_throne_kavus_ui.cancelled.connect(_refresh_campaign_graph)
	_shroud_reveal_ui = ShroudRevealController.new()
	_shroud_reveal_ui.name = "ShroudRevealUI"
	add_child(_shroud_reveal_ui)
	_shroud_reveal_ui.reveal_confirmed.connect(_on_shroud_reveal_confirmed)
	_shroud_reveal_ui.cancelled.connect(_refresh_campaign_graph)


func _load_campaign_run() -> void:
	if SceneFlowController:
		SceneFlowController.load_campaign_run_from_save()
		if SceneFlowController.pending_campaign_run:
			_run = SceneFlowController.pending_campaign_run


func _process_pending_campaign_battle_result() -> void:
	if SceneFlowController == null or SceneFlowController.pending_campaign_battle_result.is_empty():
		return
	var result := SceneFlowController.pending_campaign_battle_result.duplicate()
	SceneFlowController.pending_campaign_battle_result = {}
	_load_campaign_run()
	complete_campaign_battle(
		bool(result.get("victory", false)),
		str(result.get("node_id", "")),
		bool(result.get("safe_retreat", false)),
		int(result.get("run_sacred_fire", -1))
	)


func _show_pending_alert() -> void:
	if SceneFlowController == null or _seals_label == null:
		return
	var msg := SceneFlowController.consume_pending_alert()
	var seals := SaveSystem.get_khan_seals() if SaveSystem else 0
	var horde_clears := SaveSystem.get_horde_clears_count() if SaveSystem else 0
	if msg != "":
		_seals_label.text = "%s\nLabour seals: %d/7 | Horde: %d/8" % [msg, seals, horde_clears]
	else:
		_seals_label.text = "Labour seals: %d/7 | Horde cleared: %d/8" % [seals, horde_clears]


func _build_campaign_nodes() -> void:
	if _node_row == null:
		_build_level_buttons_fallback()
		return
	for child in _node_row.get_children():
		child.queue_free()
	for entry in KHAN_LEVELS:
		var level_id: String = entry["id"]
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(72, 72)
		var unlocked := _is_level_playable(entry)
		var cleared := SaveSystem.is_level_cleared(level_id) if SaveSystem else false
		var has_seal := SaveSystem.has_level_seal(level_id) if SaveSystem else false
		var status := "Locked"
		if cleared:
			status = "Seal" if has_seal else "Cleared"
		elif unlocked:
			status = "Open"
		btn.text = "%s\n%s" % [entry.get("short", "?"), status]
		btn.tooltip_text = _level_tooltip(entry, unlocked)
		btn.disabled = not unlocked
		if cleared:
			btn.modulate = Color(0.75, 0.95, 0.7) if has_seal else Color(0.6, 0.85, 0.65)
		elif unlocked:
			btn.modulate = Color(1.0, 0.95, 0.8)
		else:
			btn.modulate = Color(0.45, 0.45, 0.45)
		btn.pressed.connect(_on_level.bind(level_id))
		_node_row.add_child(btn)


func _is_level_playable(entry: Dictionary) -> bool:
	var level_id: String = entry["id"]
	if entry.get("tutorial", false):
		return true
	if SaveSystem == null or not SaveSystem.is_level_unlocked(level_id):
		return false
	if level_id == "level_01" and not SaveSystem.is_tutorial_completed():
		return false
	return true


func _level_tooltip(entry: Dictionary, unlocked: bool) -> String:
	var level_id: String = entry["id"]
	var text: String = entry["label"]
	if level_id == "level_01" and SaveSystem and not SaveSystem.is_tutorial_completed():
		return "%s — Complete tutorial first" % text
	if level_id == "level_08_damavand" and SaveSystem and not SaveSystem.is_level_unlocked(level_id):
		return "%s — Clear Labour 7 first" % text
	if not unlocked:
		return "%s — Locked" % text
	if ForgeService and ForgeService.forge_gate_applies_to_level(level_id):
		var rec := ForgeService.format_forge_recommendation(level_id)
		if ForgeService.is_under_forge_recommendation(level_id):
			return "%s — %s\nUnder-forged: replay earlier Labours for Star Iron, then forge at Kaveh's." % [text, rec]
		return "%s — %s" % [text, rec]
	return text


func _build_level_buttons_fallback() -> void:
	if _level_list == null:
		return
	for child in _level_list.get_children():
		child.queue_free()
	for entry in KHAN_LEVELS:
		var btn := Button.new()
		btn.text = entry["label"]
		var level_id: String = entry["id"]
		btn.disabled = not _is_level_playable(entry)
		btn.pressed.connect(_on_level.bind(level_id))
		_level_list.add_child(btn)


func _refresh_mode_buttons() -> void:
	var seals := SaveSystem.get_khan_seals() if SaveSystem else 0
	var horde_clears := SaveSystem.get_horde_clears_count() if SaveSystem else 0
	if _seals_label:
		var forge_text := ""
		if ForgeService:
			forge_text = " | Avg forge: Lv %d" % ForgeService.get_average_forge_level_floor()
		_seals_label.text = "Labour seals: %d/7 | Horde cleared: %d/8%s" % [seals, horde_clears, forge_text]
	if _endless_btn:
		_endless_btn.disabled = seals < 7
	if _gauntlet_btn:
		_gauntlet_btn.disabled = seals < 7
		_gauntlet_btn.tooltip_text = (
			"Haft-Khan Gauntlet — race all 7 Labours back-to-back; beat your ghost."
			if seals >= 7
			else "Complete all seven Labours (7 seals) to unlock the Gauntlet."
		)
	if _horde_btn:
		_horde_btn.disabled = not SaveSystem.is_tutorial_completed() if SaveSystem else true
		var horde_tip := "Survive 15 waves per Labour — clear all 8 to unlock Serpent Spire"
		if ForgeService:
			horde_tip += "\nHorde uses campaign difficulty — forge towers for later maps."
		_horde_btn.tooltip_text = horde_tip
	if _brothers_btn:
		_brothers_btn.disabled = not SaveSystem.is_tutorial_completed() if SaveSystem else true
		_brothers_btn.tooltip_text = (
			"Brothers in Arms — two heroes, shared gold, separate Sacred Fire"
		)
	if _throne_btn:
		_throne_btn.disabled = not SaveSystem.is_tutorial_completed() if SaveSystem else true
		_throne_btn.tooltip_text = "Defend the Throne — 360° arena survival"
	if _hunt_btn:
		var hunt_ready := seals >= 7 and ForgeService and ForgeService.can_enter_damavand()
		_hunt_btn.disabled = not hunt_ready
		_hunt_btn.tooltip_text = (
			"Hunt for Zahhak"
			if hunt_ready
			else "Need 7 seals + 1 Elite tower at Kaveh's Forge"
		)
	if _roguelite_btn:
		_roguelite_btn.disabled = not SaveSystem.is_tutorial_completed() if SaveSystem else true
		_roguelite_btn.tooltip_text = "Branching campaign run — draft towers, scavenge materials, reach Damavand"
	if _forge_btn:
		var elite := ForgeService.count_elite_towers() if ForgeService else 0
		_forge_btn.text = "Kaveh's Forge (%d Elite)" % elite


func _on_level(level_id: String) -> void:
	var launch := BattleLaunchData.new()
	launch.level_id = level_id
	SceneFlowController.go_to_battle(launch)


func _on_roguelite() -> void:
	if SaveSystem and not SaveSystem.is_tutorial_completed():
		return
	_load_campaign_run()
	if _run != null:
		_show_campaign_run_panel()
		return
	var pool := SaveSystem.get_unlocked_tower_pool() if SaveSystem else ContentCatalog.get_starter_tower_ids()
	var shroud_unlocked := SaveSystem.is_level_cleared("level_08_damavand") if SaveSystem else false
	_tower_draft.show_start_draft(pool, shroud_unlocked)


func _on_draft_confirmed(tower_ids: Array[String], ahrimans_shroud_enabled: bool = false) -> void:
	if _pending_gauntlet_draft:
		_pending_gauntlet_draft = false
		var run := GauntletRunState.new()
		run.start_run(tower_ids)
		if SceneFlowController:
			SceneFlowController.pending_gauntlet_run = run
			AnalyticsService.gauntlet_started()
			SceneFlowController.go_to_battle(run.build_launch())
		return
	if _pending_tower_pick_node_id != "" and _run != null:
		if not tower_ids.is_empty():
			_run.add_run_tower(str(tower_ids[0]))
		_pending_tower_pick_node_id = ""
		_persist_and_refresh()
		return
	_run = CampaignRunState.new()
	if ahrimans_shroud_enabled:
		_run.enable_ahrimans_shroud()
	_run.generate_run()
	_run.set_run_towers(tower_ids)
	if SceneFlowController:
		SceneFlowController.pending_campaign_run = _run
		SceneFlowController.persist_campaign_run()
	_show_campaign_run_panel()


func _on_draft_cancelled() -> void:
	_pending_gauntlet_draft = false


func _show_campaign_run_panel() -> void:
	if _campaign_panel:
		_campaign_panel.visible = true
	_refresh_campaign_graph()


func _hide_campaign_run_panel() -> void:
	if _campaign_panel:
		_campaign_panel.visible = false


func _refresh_campaign_graph() -> void:
	if _run == null or _campaign_canvas == null:
		return
	for child in _campaign_canvas.get_children():
		child.queue_free()
	var reachable := _run.get_reachable_node_ids()
	var current_id := _run.current_node_id
	if _campaign_desc:
		var current := _run.get_current_node()
		_campaign_desc.text = (
			"Campaign Run — Act %d | Loadout: %s | Pick a reachable node."
			% [
				_run.act_index,
				RelicSlotHelper.format_loadout_line(_run.run_tower_ids, _run.tower_relic_slots),
			]
		)
		if not current.is_empty():
			_campaign_desc.text += " Current: %s" % current.get("label", current_id)
		if _run.pending_kavus_folly:
			_campaign_desc.text += "\nKay Kavus's throne will strike in your next battle!"
		if _run.is_shroud_active():
			_campaign_desc.text += (
				"\nAhriman's Shroud — Sacred Fire: %d. Reveal nodes before entering."
				% _run.run_sacred_fire
			)
	for n in _run.nodes:
		var node_id := str(n.get("id", ""))
		var pos_data: Variant = n.get("position", {})
		var pos := Vector2(float(pos_data.get("x", 0)), float(pos_data.get("y", 0)))
		var btn := Button.new()
		btn.text = _node_button_text(n, node_id in reachable, node_id == current_id)
		btn.position = pos
		btn.custom_minimum_size = Vector2(140, 44)
		var cleared := bool(n.get("cleared", false))
		var node_type := str(n.get("type", ""))
		var revealed := _run.is_node_revealed(node_id)
		if cleared:
			btn.modulate = Color(0.5, 0.8, 0.5)
			btn.disabled = true
		elif node_id in reachable:
			if _run.is_shroud_active() and not revealed:
				btn.modulate = Color(0.15, 0.12, 0.2)
				btn.tooltip_text = "Shrouded — tap to spend Sacred Fire and reveal."
			elif node_type == CampaignRunState.NODE_THRONE_KAVUS:
				btn.modulate = Color(1.0, 0.72, 0.35)
				btn.tooltip_text = "High risk — Kay Kavus's flying throne may crush friend and foe."
			else:
				btn.modulate = Color(1.0, 0.95, 0.75)
			btn.pressed.connect(_on_campaign_node_pressed.bind(node_id))
		elif node_id == current_id:
			btn.modulate = Color(0.8, 0.9, 1.0)
			btn.disabled = true
		else:
			if _run.is_shroud_active() and not revealed:
				btn.modulate = Color(0.15, 0.12, 0.2)
			else:
				btn.modulate = Color(0.45, 0.45, 0.45)
			btn.disabled = true
		_campaign_canvas.add_child(btn)
	_draw_campaign_edges()


func _draw_campaign_edges() -> void:
	if _run == null or _campaign_canvas == null:
		return
	for n in _run.nodes:
		var from_id := str(n.get("id", ""))
		var from_pos := _node_position(from_id)
		var edges: Variant = n.get("edges", [])
		if edges is Array:
			for edge_id in edges:
				var to_pos := _node_position(str(edge_id))
				var line := Line2D.new()
				line.width = 2.0
				line.default_color = Color(0.6, 0.55, 0.4, 0.7)
				line.points = PackedVector2Array([from_pos + Vector2(70, 22), to_pos + Vector2(70, 22)])
				_campaign_canvas.add_child(line)
				_campaign_canvas.move_child(line, 0)


func _node_position(node_id: String) -> Vector2:
	var node := _run.get_node(node_id)
	var pos_data: Variant = node.get("position", {})
	return Vector2(float(pos_data.get("x", 0)), float(pos_data.get("y", 0)))


func _node_button_text(node: Dictionary, _reachable: bool, _is_current: bool) -> String:
	var node_id := str(node.get("id", ""))
	var label := str(node.get("label", node_id))
	if _run == null or not _run.is_shroud_active():
		return label
	if _run.is_node_revealed(node_id):
		return label
	return "???"


func _on_campaign_node_pressed(node_id: String) -> void:
	if _run == null:
		return
	if _run.is_shroud_active() and not _run.is_node_revealed(node_id):
		var node := _run.get_node(node_id)
		if _run.can_reveal_node(node_id):
			_shroud_reveal_ui.show_reveal_offer(
				node_id,
				_run.get_reveal_cost(node),
				_run.run_sacred_fire
			)
		elif SceneFlowController:
			SceneFlowController.pending_alert = "Not enough Sacred Fire to reveal this node."
		return
	if not _run.advance_to_node(node_id):
		return
	if SceneFlowController:
		SceneFlowController.pending_campaign_run = _run
		SceneFlowController.persist_campaign_run()
	var node := _run.get_node(node_id)
	match str(node.get("type", "")):
		CampaignRunState.NODE_ANVIL:
			_anvil_ui.show_for_towers(_run.run_tower_ids)
		CampaignRunState.NODE_SHRINE:
			_shrine_ui.show_shrine_pick(
				_run.run_tower_ids,
				_run.tower_relic_slots,
				_run.active_companion_id
			)
		CampaignRunState.NODE_THRONE_KAVUS:
			_throne_kavus_ui.show_offer()
		CampaignRunState.NODE_SKIRMISH, CampaignRunState.NODE_LABOUR_BOSS, CampaignRunState.NODE_FINALE:
			_launch_campaign_battle(node)
		_:
			_refresh_campaign_graph()


func _on_anvil_upgrade(tower_id: String) -> void:
	if _run == null:
		return
	_run.add_run_tower_upgrade(tower_id)
	_run.mark_node_cleared(_run.current_node_id)
	_persist_and_refresh()
	if bool(_run.get_current_node().get("grants_tower_pick", false)):
		_offer_mid_run_tower_pick(_run.current_node_id)


func _on_shrine_relic(tower_id: String, relic_id: String) -> void:
	if _run == null:
		return
	_run.slot_relic(relic_id, tower_id)
	_run.mark_node_cleared(_run.current_node_id)
	_persist_and_refresh()


func _on_shrine_companion(companion_id: String) -> void:
	if _run == null or companion_id == "":
		return
	_run.set_active_companion(companion_id)
	_persist_and_refresh()


func _on_throne_kavus_accepted() -> void:
	if _run == null:
		return
	_run.pending_kavus_folly = true
	_run.mark_node_cleared(_run.current_node_id)
	if SceneFlowController:
		SceneFlowController.pending_alert = "Kay Kavus's throne will follow you into the next battle!"
	_persist_and_refresh()


func _on_throne_kavus_declined() -> void:
	if _run == null:
		return
	_run.mark_node_cleared(_run.current_node_id)
	_persist_and_refresh()


func _on_shroud_reveal_confirmed(node_id: String) -> void:
	if _run == null:
		return
	if not _run.reveal_node(node_id):
		if SceneFlowController:
			SceneFlowController.pending_alert = "Could not reveal node."
		return
	_persist_and_refresh()


func _offer_mid_run_tower_pick(node_id: String) -> void:
	_pending_tower_pick_node_id = node_id
	var pool := SaveSystem.get_unlocked_tower_pool() if SaveSystem else []
	_tower_draft.show_add_one_draft(pool, _run.run_tower_ids)


func _launch_campaign_battle(node: Dictionary) -> void:
	if _run == null:
		return
	var launch := BattleLaunchData.new()
	launch.is_campaign_run = true
	launch.campaign_node_id = str(node.get("id", ""))
	launch.level_id = str(node.get("level_id", "level_01"))
	launch.run_tower_ids = _run.run_tower_ids.duplicate()
	launch.run_tower_upgrades = _run.run_tower_upgrades.duplicate()
	launch.tower_relic_slots = _run.tower_relic_slots.duplicate()
	launch.active_relic_ids = _run.active_relic_ids.duplicate()
	launch.active_companion_id = _run.active_companion_id
	var node_type := str(node.get("type", ""))
	if node_type == CampaignRunState.NODE_SKIRMISH:
		launch.skirmish_waves = CampaignRunGenerator.SKIRMISH_WAVES
	if _run.pending_kavus_folly:
		launch.kavus_folly_active = true
		_run.pending_kavus_folly = false
	if _run.is_shroud_active():
		launch.ahrimans_shroud_enabled = true
		launch.run_sacred_fire = _run.run_sacred_fire
	if SceneFlowController:
		SceneFlowController.pending_campaign_run = _run
		SceneFlowController.persist_campaign_run()
		SceneFlowController.go_to_battle(launch)


func _persist_and_refresh() -> void:
	if SceneFlowController:
		SceneFlowController.pending_campaign_run = _run
		SceneFlowController.persist_campaign_run()
	_refresh_campaign_graph()


func complete_campaign_battle(
	victory: bool,
	node_id: String,
	safe_retreat: bool = false,
	run_sacred_fire: int = -1
) -> void:
	if _run == null:
		_load_campaign_run()
	if _run == null:
		return
	if (victory or safe_retreat) and run_sacred_fire >= 0 and _run.is_shroud_active():
		_run.sync_sacred_fire_from_battle(run_sacred_fire)
	if victory and not safe_retreat and node_id != "":
		_run.mark_node_cleared(node_id)
		var node := _run.get_node(node_id)
		if bool(node.get("grants_tower_pick", false)):
			_offer_mid_run_tower_pick(node_id)
	elif not victory:
		if SceneFlowController:
			SceneFlowController.clear_campaign_run()
		_run = null
		_hide_campaign_run_panel()
		return
	if _run.is_run_complete():
		if SceneFlowController:
			SceneFlowController.clear_campaign_run()
			SceneFlowController.pending_alert = "Campaign Run complete!"
		_run = null
		_hide_campaign_run_panel()
		return
	_persist_and_refresh()
	_show_campaign_run_panel()


func _on_endless() -> void:
	var launch := BattleLaunchData.new()
	launch.level_id = "level_01"
	launch.is_endless_mode = true
	SceneFlowController.go_to_battle(launch)


func _on_gauntlet() -> void:
	if SaveSystem == null or SaveSystem.get_khan_seals() < 7:
		return
	_pending_gauntlet_draft = true
	var pool := SaveSystem.get_unlocked_tower_pool()
	_tower_draft.show_gauntlet_draft(pool)


func _on_horde_menu() -> void:
	if _horde_picker == null:
		return
	_horde_picker.visible = not _horde_picker.visible
	if _horde_picker.visible:
		_build_horde_picker()


func _build_horde_picker() -> void:
	if _horde_list == null:
		return
	for child in _horde_list.get_children():
		child.queue_free()
	for entry in KHAN_LEVELS:
		if entry.get("tutorial", false):
			continue
		var level_id: String = entry["id"]
		if not _is_level_playable(entry):
			continue
		var btn := Button.new()
		var cleared := SaveSystem.is_horde_cleared(level_id) if SaveSystem else false
		btn.text = "%s — Horde%s" % [entry["label"], " ✓" if cleared else ""]
		btn.pressed.connect(_on_horde_level.bind(level_id))
		_horde_list.add_child(btn)


func _on_horde_level(level_id: String) -> void:
	if _horde_picker:
		_horde_picker.visible = false
	var launch := BattleLaunchData.new()
	launch.level_id = level_id
	launch.is_horde_mode = true
	SceneFlowController.go_to_battle(launch)


func _setup_brothers_ui() -> void:
	_coop_hero_picker = CoopHeroPickerController.new()
	_coop_hero_picker.name = "CoopHeroPicker"
	add_child(_coop_hero_picker)
	_coop_hero_picker.confirmed.connect(_on_brothers_heroes_confirmed)
	_brothers_picker = get_node_or_null("%BrothersPickerPanel") as Panel
	_brothers_list = get_node_or_null("%BrothersLevelList") as VBoxContainer


func _on_brothers_menu() -> void:
	if _coop_hero_picker:
		_coop_hero_picker.show_picker()


func _on_brothers_heroes_confirmed(player_heroes: Array[String]) -> void:
	_pending_brothers_heroes = player_heroes.duplicate()
	if _brothers_picker:
		_brothers_picker.visible = true
		_build_brothers_picker()


func _build_brothers_picker() -> void:
	if _brothers_list == null:
		return
	for child in _brothers_list.get_children():
		child.queue_free()
	for entry in KHAN_LEVELS:
		if entry.get("tutorial", false):
			continue
		var level_id: String = entry["id"]
		if not _is_level_playable(entry):
			continue
		var btn := Button.new()
		btn.text = "%s — Brothers" % entry["label"]
		btn.pressed.connect(_on_brothers_level.bind(level_id))
		_brothers_list.add_child(btn)


func _on_brothers_level(level_id: String) -> void:
	if _brothers_picker:
		_brothers_picker.visible = false
	var launch := BattleLaunchData.new()
	launch.level_id = level_id
	launch.is_brothers_mode = true
	launch.coop_player_heroes = _pending_brothers_heroes.duplicate()
	if launch.coop_player_heroes.size() < 2:
		launch.coop_player_heroes = CoopPlayerManager.BROTHERS_HERO_POOL.duplicate()
	SceneFlowController.go_to_battle(launch)


func _on_throne() -> void:
	var launch := BattleLaunchData.new()
	launch.level_id = ContentCatalog.THRONE_ARENA_LEVEL_ID
	launch.is_throne_defense_mode = true
	SceneFlowController.go_to_battle(launch)


func _on_hunt() -> void:
	var launch := BattleLaunchData.new()
	launch.level_id = "level_08_damavand"
	launch.is_hunt_mode = true
	SceneFlowController.go_to_battle(launch)


func _setup_meta_panels() -> void:
	if DailyMissionService:
		DailyMissionService.refresh_if_needed()
	_equipment_ui = EquipmentScreenController.new()
	_equipment_ui.name = "EquipmentScreen"
	add_child(_equipment_ui)
	_daily_missions_ui = DailyMissionsPanelController.new()
	_daily_missions_ui.name = "DailyMissionsPanel"
	add_child(_daily_missions_ui)
	var equip_btn := Button.new()
	equip_btn.text = "Equipment"
	equip_btn.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	equip_btn.position = Vector2(140, 12)
	equip_btn.pressed.connect(func() -> void:
		if _equipment_ui:
			_equipment_ui.open(self)
	)
	add_child(equip_btn)
	var missions_btn := Button.new()
	missions_btn.text = "Daily Missions"
	missions_btn.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	missions_btn.position = Vector2(260, 12)
	missions_btn.pressed.connect(func() -> void:
		if _daily_missions_ui:
			_daily_missions_ui.open(self)
	)
	add_child(missions_btn)


func _on_forge() -> void:
	SceneFlowController.go_to_forge(true)


func _on_back() -> void:
	SceneFlowController.go_to_main_menu()
