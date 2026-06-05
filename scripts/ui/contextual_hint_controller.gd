class_name ContextualHintController
extends CanvasLayer

const HINT_TOWER_PANEL := "hint_tower_panel"
const HINT_FORGE := "hint_forge"
const HINT_EARLY_CALL := "hint_early_call"
const HINT_TETHER := "hint_tether"

@onready var _root: Control = %Root
@onready var _panel: Panel = %HintPanel
@onready var _label: Label = %HintLabel
@onready var _got_it_btn: Button = %GotItButton

var context: BattleContext = null
var _hud: BattleHudController = null
var _queue: Array[Dictionary] = []
var _active: bool = false
var _tower_build_count: int = 0
var _pending_init: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	if _got_it_btn:
		_got_it_btn.pressed.connect(_on_got_it)
	if not _pending_init.is_empty():
		_begin_hints()


func initialize(ctx: BattleContext, hud: BattleHudController) -> void:
	_pending_init = {
		"context": ctx,
		"hud": hud,
	}
	if is_node_ready():
		_begin_hints()
	else:
		call_deferred("_begin_hints")


func _begin_hints() -> void:
	if _pending_init.is_empty():
		return
	context = _pending_init.get("context") as BattleContext
	_hud = _pending_init.get("hud") as BattleHudController
	_pending_init.clear()
	if context == null or context.tutorial_active:
		return
	_connect_events()


func _connect_events() -> void:
	CombatEvents.tower_built.connect(_on_tower_built)
	if context and context.bridge:
		context.bridge.intermission_started.connect(_on_intermission_started)
	if context and context.tower_manager:
		context.tower_manager.tower_spot_opened.connect(_on_tower_spot_opened)


func _on_tower_built(_tower_id: String) -> void:
	_tower_build_count += 1
	if _tower_build_count == 1:
		_enqueue_hint(
			HINT_TOWER_PANEL,
			"Tap a placed tower to Upgrade it or Sell it for a refund."
		)
	elif _tower_build_count == 2:
		_enqueue_hint(
			HINT_FORGE,
			"Tap Forge to fuse two adjacent towers into a stronger one."
		)


func _on_intermission_started(_preview_text: String, _max_bonus_gold: int) -> void:
	_enqueue_hint(
		HINT_EARLY_CALL,
		"Press Start Now between waves for bonus Gold."
	)


func _on_tower_spot_opened(_spot: BuildSpot) -> void:
	_enqueue_hint(
		HINT_TETHER,
		"Use Sacred Tether to bond Rostam to a nearby tower for a damage boost."
	)


func _enqueue_hint(hint_id: String, text: String) -> void:
	if SaveSystem and SaveSystem.has_seen_hint(hint_id):
		return
	for entry in _queue:
		if entry.get("id", "") == hint_id:
			return
	_queue.append({"id": hint_id, "text": text})
	if not _active:
		_show_next()


func _show_next() -> void:
	if _queue.is_empty():
		_active = false
		visible = false
		return
	var entry: Dictionary = _queue[0]
	_active = true
	visible = true
	if _label:
		_label.text = str(entry.get("text", ""))


func _on_got_it() -> void:
	if _queue.is_empty():
		return
	var entry: Dictionary = _queue.pop_front()
	var hint_id: String = str(entry.get("id", ""))
	if SaveSystem and hint_id != "":
		SaveSystem.mark_hint_seen(hint_id)
	_show_next()


func _exit_tree() -> void:
	if CombatEvents.tower_built.is_connected(_on_tower_built):
		CombatEvents.tower_built.disconnect(_on_tower_built)
	if context and context.bridge and context.bridge.intermission_started.is_connected(_on_intermission_started):
		context.bridge.intermission_started.disconnect(_on_intermission_started)
	if context and context.tower_manager and context.tower_manager.tower_spot_opened.is_connected(_on_tower_spot_opened):
		context.tower_manager.tower_spot_opened.disconnect(_on_tower_spot_opened)
