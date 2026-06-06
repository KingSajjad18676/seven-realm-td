extends Control

## Daily missions panel — 3 daily quests + Royal Bounty bonus slots.


var _panel: Panel = null
var _mission_list: VBoxContainer = null
var _status_label: Label = null


func open(parent: Control) -> void:
	if DailyMissionService:
		DailyMissionService.refresh_if_needed()
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
	_panel.name = "DailyMissionsPanel"
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
	title.text = "Daily Missions"
	root.add_child(title)

	_status_label = Label.new()
	root.add_child(_status_label)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(scroll)

	_mission_list = VBoxContainer.new()
	_mission_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_mission_list)

	var bounty_btn := Button.new()
	bounty_btn.text = "Use Royal Bounty (+3 missions)"
	bounty_btn.pressed.connect(_on_use_bounty)
	root.add_child(bounty_btn)

	var close_btn := Button.new()
	close_btn.text = "Close"
	close_btn.pressed.connect(close)
	root.add_child(close_btn)


func _refresh() -> void:
	for child in _mission_list.get_children():
		child.queue_free()
	if not DailyMissionService:
		return
	var missions := DailyMissionService.get_active_missions()
	_status_label.text = "%d active missions today" % missions.size()
	for entry in missions:
		var row := _make_mission_row(entry)
		_mission_list.add_child(row)


func _make_mission_row(entry: Dictionary) -> Control:
	var box := VBoxContainer.new()
	var desc := Label.new()
	desc.text = str(entry.get("description", ""))
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(desc)
	var progress := int(entry.get("progress", 0))
	var target := int(entry.get("goal_target", 1))
	var prog := Label.new()
	prog.text = "Progress: %d / %d" % [progress, target]
	box.add_child(prog)
	if bool(entry.get("claimed", false)):
		var done := Label.new()
		done.text = "Claimed"
		box.add_child(done)
	elif progress >= target:
		var claim := Button.new()
		var mission_id := str(entry.get("mission_id", ""))
		claim.text = "Claim Daily Loot Chest"
		claim.pressed.connect(func() -> void:
			_claim_mission(mission_id)
		)
		box.add_child(claim)
	return box


func _claim_mission(mission_id: String) -> void:
	if not DailyMissionService:
		return
	var reward := DailyMissionService.claim_mission(mission_id)
	if reward.is_empty():
		return
	if reward.get("type", "") == "equipment" and ContentRegistry:
		var piece := ContentRegistry.get_equipment_piece(str(reward.get("piece_id", "")))
		if piece and SceneFlowController:
			SceneFlowController.pending_alert = "Equipment acquired: %s" % piece.display_name
	elif reward.get("type", "") == "tokens" and SceneFlowController:
		SceneFlowController.pending_alert = "Duplicate pool — %d Forge Tokens" % int(reward.get("amount", 0))
	_refresh()


func _on_use_bounty() -> void:
	if StoreService and StoreService.consume_royal_bounty():
		if SceneFlowController:
			SceneFlowController.pending_alert = "Royal Bounty — 3 bonus missions added!"
		_refresh()
	elif SaveSystem and SaveSystem.get_royal_bounty_tickets() <= 0:
		if StoreService:
			StoreService.purchase("royal_bounty_ticket")
		_refresh()
	else:
		if SceneFlowController:
			SceneFlowController.pending_alert = "Royal Bounty already used today."
