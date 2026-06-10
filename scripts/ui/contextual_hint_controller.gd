class_name ContextualHintController
extends CanvasLayer

const HINT_TOWER_PANEL := "hint_tower_panel"
const HINT_RESONANCE := "hint_resonance"
const HINT_EARLY_CALL := "hint_early_call"
const HINT_TETHER := "hint_tether"
const HINT_NAFT := "hint_naft_trap"

@onready var _root: Control = %Root
@onready var _panel: Panel = %HintPanel
@onready var _label: Label = %HintLabel
@onready var _got_it_btn: Button = %GotItButton

var context: BattleContext = null
var _hud: BattleHudController = null
var _queue: Array[Dictionary] = []
var _active: bool = false
var _tower_build_count: int = 0
var _waves_cleared: int = 0
var _sacred_fire_built: bool = false
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
	CombatEvents.wave_completed.connect(_on_wave_completed)
	if context and context.bridge:
		context.bridge.intermission_started.connect(_on_intermission_started)
	if context and context.tower_manager:
		context.tower_manager.tower_opened.connect(_on_tower_opened)
	CombatEvents.tower_resonance_linked.connect(_on_resonance_linked)


func _on_tower_built(tower_id: String) -> void:
	_tower_build_count += 1
	if tower_id == "tower_sacred_fire":
		_sacred_fire_built = true
		_try_naft_hint()
	if _tower_build_count == 1:
		_enqueue_hint(
			HINT_TOWER_PANEL,
			"Tap a placed tower to Upgrade it or Sell it for a refund."
		)


func _on_wave_completed(_wave_index: int) -> void:
	_waves_cleared += 1
	_try_naft_hint()


func _try_naft_hint() -> void:
	if not _sacred_fire_built or _waves_cleared < 2:
		return
	if context and context.hero_manager and context.hero_manager.hero:
		var hero := context.hero_manager.hero
		if hero.data == null or hero.data.secondary_skill_id != "rostam_naft":
			return
	_enqueue_hint(
			HINT_NAFT,
			"Spill Naft on the path, then let Sacred Fire ignite it for a blazing trap."
		)


func _on_intermission_started(_preview_text: String, _max_bonus_gold: int) -> void:
	_enqueue_hint(
		HINT_EARLY_CALL,
		"Press Start Now between waves for bonus Gold."
	)


func _on_tower_opened(_tower: TowerController) -> void:
	_enqueue_hint(
		HINT_TETHER,
		"Tap a placed tower → Tether to bond Rostam for a damage boost while you stay nearby."
	)


func _on_resonance_linked(_combo_id: String) -> void:
	_enqueue_hint(
		HINT_RESONANCE,
		"Tower Resonance! Adjacent towers link up and share powerful passive buffs."
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
	if CombatEvents.wave_completed.is_connected(_on_wave_completed):
		CombatEvents.wave_completed.disconnect(_on_wave_completed)
	if context and context.bridge and context.bridge.intermission_started.is_connected(_on_intermission_started):
		context.bridge.intermission_started.disconnect(_on_intermission_started)
	if context and context.tower_manager and context.tower_manager.tower_opened.is_connected(_on_tower_opened):
		context.tower_manager.tower_opened.disconnect(_on_tower_opened)
	if CombatEvents.tower_resonance_linked.is_connected(_on_resonance_linked):
		CombatEvents.tower_resonance_linked.disconnect(_on_resonance_linked)
