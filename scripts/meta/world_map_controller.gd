extends Control

const KHAN_LEVELS: Array[Dictionary] = [
	{"id": "level_00_tutorial", "label": "Tutorial", "short": "T", "tutorial": true},
	{"id": "level_01", "label": "Khan 1", "short": "1"},
	{"id": "level_02", "label": "Khan 2", "short": "2"},
	{"id": "level_03", "label": "Khan 3", "short": "3"},
	{"id": "level_04", "label": "Khan 4", "short": "4"},
	{"id": "level_05", "label": "Khan 5", "short": "5"},
	{"id": "level_06", "label": "Khan 6", "short": "6"},
	{"id": "level_07", "label": "Khan 7", "short": "7"},
	{"id": "level_08_damavand", "label": "Damavand", "short": "D"},
]

@onready var _scroll: ScrollContainer = $ScrollContainer
@onready var _level_list: VBoxContainer = $ScrollContainer/LevelList
@onready var _node_row: HBoxContainer = $ScrollContainer/CampaignNodeRow
@onready var _back_btn: Button = $BackButton
@onready var _roguelite_btn: Button = %RogueliteButton
@onready var _endless_btn: Button = %EndlessButton
@onready var _horde_btn: Button = %HordeButton
@onready var _hunt_btn: Button = %HuntButton
@onready var _seals_label: Label = %SealsLabel
@onready var _forge_btn: Button = %ForgeLinkButton
@onready var _horde_picker: Panel = %HordePickerPanel
@onready var _horde_list: VBoxContainer = %HordeLevelList


func _ready() -> void:
	if _level_list:
		_level_list.visible = false
	_build_campaign_nodes()
	if _back_btn:
		_back_btn.pressed.connect(_on_back)
	if _roguelite_btn:
		_roguelite_btn.pressed.connect(_on_roguelite)
	if _endless_btn:
		_endless_btn.pressed.connect(_on_endless)
	if _horde_btn:
		_horde_btn.pressed.connect(_on_horde_menu)
	if _hunt_btn:
		_hunt_btn.pressed.connect(_on_hunt)
	if _forge_btn:
		_forge_btn.pressed.connect(_on_forge)
	_refresh_mode_buttons()
	_show_pending_alert()


func _show_pending_alert() -> void:
	if SceneFlowController == null or _seals_label == null:
		return
	var msg := SceneFlowController.consume_pending_alert()
	var seals := SaveSystem.get_khan_seals() if SaveSystem else 0
	var horde_clears := SaveSystem.get_horde_clears_count() if SaveSystem else 0
	if msg != "":
		_seals_label.text = "%s\nKhan seals: %d/7 | Horde: %d/8" % [msg, seals, horde_clears]
	else:
		_seals_label.text = "Khan seals: %d/7 | Horde cleared: %d/8" % [seals, horde_clears]


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
		return "%s — Clear Khan 7 first" % text
	if not unlocked:
		return "%s — Locked" % text
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
		_seals_label.text = "Khan seals: %d/7 | Horde cleared: %d/8" % [seals, horde_clears]
	if _endless_btn:
		_endless_btn.disabled = seals < 7
	if _horde_btn:
		_horde_btn.disabled = not SaveSystem.is_tutorial_completed() if SaveSystem else true
		_horde_btn.tooltip_text = "Survive 15 waves per Khan — clear all 8 to unlock Serpent Spire"
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
	if _forge_btn:
		var elite := ForgeService.count_elite_towers() if ForgeService else 0
		_forge_btn.text = "Kaveh's Forge (%d Elite)" % elite


func _on_level(level_id: String) -> void:
	var launch := BattleLaunchData.new()
	launch.level_id = level_id
	SceneFlowController.go_to_battle(launch)


func _on_roguelite() -> void:
	var has_active_run := SceneFlowController.pending_roguelite_run != null
	if not has_active_run and SaveSystem:
		has_active_run = not SaveSystem.get_roguelite_run().is_empty()
	SceneFlowController.go_to_roguelite_map(not has_active_run)


func _on_endless() -> void:
	var launch := BattleLaunchData.new()
	launch.level_id = "level_01"
	launch.is_endless_mode = true
	SceneFlowController.go_to_battle(launch)


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


func _on_hunt() -> void:
	var launch := BattleLaunchData.new()
	launch.level_id = "level_08_damavand"
	launch.is_hunt_mode = true
	SceneFlowController.go_to_battle(launch)


func _on_forge() -> void:
	SceneFlowController.go_to_forge(true)


func _on_back() -> void:
	SceneFlowController.go_to_main_menu()
