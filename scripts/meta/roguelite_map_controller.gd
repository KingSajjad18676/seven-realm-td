extends Control

@onready var _title: Label = $Title
@onready var _node_row: HBoxContainer = $NodeRow
@onready var _desc: Label = $DescLabel
@onready var _action_btn: Button = $ActionButton
@onready var _back_btn: Button = $BackButton

var _run: RogueliteRunState = RogueliteRunState.new()
var _relic_picker: RelicSlotPickerController = null


func _ready() -> void:
	if SceneFlowController and SceneFlowController.pending_roguelite_run:
		_run = SceneFlowController.pending_roguelite_run
	else:
		_run.generate_run()
		if SceneFlowController:
			SceneFlowController.pending_roguelite_run = _run
			SceneFlowController.persist_roguelite_run()
	_relic_picker = RelicSlotPickerController.new()
	_relic_picker.name = "RelicPicker"
	add_child(_relic_picker)
	_relic_picker.relic_slotted.connect(_on_relic_slotted)
	_relic_picker.cancelled.connect(_on_relic_pick_cancelled)
	_refresh()
	if _action_btn:
		_action_btn.pressed.connect(_on_action)
	if _back_btn:
		_back_btn.pressed.connect(_on_back)


func _roguelite_tower_ids() -> Array[String]:
	if SaveSystem:
		return SaveSystem.get_unlocked_tower_pool()
	return ContentCatalog.get_starter_tower_ids()


func _refresh() -> void:
	if _node_row:
		for c in _node_row.get_children():
			c.queue_free()
		for i in _run.nodes.size():
			var n: Dictionary = _run.nodes[i]
			var btn := Button.new()
			var label_text: String = str(n.get("label", n.get("type", "?")))
			btn.text = label_text
			btn.disabled = i != _run.current_index
			if i < _run.current_index:
				btn.modulate = Color(0.5, 0.8, 0.5)
			_node_row.add_child(btn)
	var node := _run.get_current_node()
	if _desc:
		_desc.text = "Node %d/%d: %s" % [
			_run.current_index + 1,
			_run.nodes.size(),
			node.get("type", ""),
		]
	if _action_btn:
		match node.get("type", ""):
			"rest":
				_action_btn.text = "Pick a relic"
			"elite", "battle":
				_action_btn.text = "Fight"
			_:
				_action_btn.text = "Continue"


func _on_action() -> void:
	var node := _run.get_current_node()
	AnalyticsService.roguelite_node_selected(str(node.get("type", "")))
	match node.get("type", ""):
		"rest":
			_pick_relic()
		"battle", "elite":
			_start_battle(str(node.get("level_id", "level_01")))
		_:
			_advance_run()


func _pick_relic() -> void:
	var picks := RelicSlotHelper.pick_relic_pool(
		_roguelite_tower_ids(),
		_run.tower_relic_slots,
		3
	)
	if picks.is_empty():
		_advance_run()
		return
	_relic_picker.show_pick(
		_roguelite_tower_ids(),
		_run.tower_relic_slots,
		"Sacred Rest — Relics of the Shahs"
	)


func _on_relic_slotted(tower_id: String, relic_id: String) -> void:
	_run.slot_relic(relic_id, tower_id)
	if _desc:
		var relic := ContentRegistry.get_relic(relic_id) if ContentRegistry else null
		_desc.text = "Relic slotted: %s" % (relic.title if relic else relic_id)
	get_tree().create_timer(0.6).timeout.connect(_advance_run, CONNECT_ONE_SHOT)


func _on_relic_pick_cancelled() -> void:
	if _desc:
		_desc.text = "No relic chosen."


func _start_battle(level_id: String) -> void:
	var launch := BattleLaunchData.new()
	launch.level_id = level_id
	launch.is_roguelite_run = true
	launch.tower_relic_slots = _run.tower_relic_slots.duplicate()
	launch.active_relic_ids = _run.active_relic_ids.duplicate()
	launch.roguelite_node_index = _run.current_index
	SceneFlowController.pending_roguelite_run = _run
	SceneFlowController.persist_roguelite_run()
	SceneFlowController.go_to_battle(launch)


func _advance_run() -> void:
	if not _run.advance():
		if SceneFlowController:
			SceneFlowController.clear_roguelite_run()
		if _desc:
			_desc.text = "Run complete! Return to campaign."
		if _action_btn:
			_action_btn.text = "Return to map"
			_action_btn.pressed.disconnect(_on_action)
			_action_btn.pressed.connect(func() -> void:
				SceneFlowController.clear_roguelite_run()
				SceneFlowController.go_to_world_map()
			)
		return
	if SceneFlowController:
		SceneFlowController.persist_roguelite_run()
	_refresh()


func _on_back() -> void:
	SceneFlowController.go_to_world_map()
