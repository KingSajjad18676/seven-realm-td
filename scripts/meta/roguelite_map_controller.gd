extends Control

@onready var _title: Label = $Title
@onready var _node_row: HBoxContainer = $NodeRow
@onready var _desc: Label = $DescLabel
@onready var _action_btn: Button = $ActionButton
@onready var _back_btn: Button = $BackButton

var _run: RogueliteRunState = RogueliteRunState.new()


func _ready() -> void:
	if SceneFlowController and SceneFlowController.pending_roguelite_run:
		_run = SceneFlowController.pending_roguelite_run
	else:
		_run.generate_run()
		if SceneFlowController:
			SceneFlowController.pending_roguelite_run = _run
			SceneFlowController.persist_roguelite_run()
	_refresh()
	if _action_btn:
		_action_btn.pressed.connect(_on_action)
	if _back_btn:
		_back_btn.pressed.connect(_on_back)


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
	var relics: Array[RelicData] = []
	if ContentRegistry:
		relics = ContentRegistry.get_all_relics()
	if relics.is_empty():
		_advance_run()
		return
	var pick: RelicData = relics[randi() % relics.size()]
	_run.relic_ids.append(pick.relic_id)
	if _desc:
		_desc.text = "Relic acquired: %s" % pick.title
	get_tree().create_timer(1.0).timeout.connect(_advance_run, CONNECT_ONE_SHOT)


func _start_battle(level_id: String) -> void:
	var launch := BattleLaunchData.new()
	launch.level_id = level_id
	launch.is_roguelite_run = true
	launch.active_relic_ids = _run.relic_ids.duplicate()
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
