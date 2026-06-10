class_name TutorialController
extends CanvasLayer

const DIM_ALPHA_COACH := 0.30
const DIM_ALPHA_MAP := 0.20
const COACH_CENTER := {"left": -360.0, "top": -110.0, "right": 360.0, "bottom": 110.0}
const COACH_BOTTOM := {"left": -360.0, "top": -200.0, "right": 360.0, "bottom": -20.0}
const PLAYFIELD_TOP := 48.0
const PLAYFIELD_BOTTOM := 652.0

enum StepAdvance {
	GOT_IT,
	TOWER_BUILT,
	WAVE_STARTED,
	HERO_MOVED,
	HERO_ATTACK,
	HERO_DODGE,
	HERO_SKILL,
	CLEANSE,
	HIJACK_RECOVERED,
	FATE_SELECTED,
	MATERIAL_COLLECTED,
	VICTORY,
}

@onready var _root: Control = %Root
@onready var _dim: ColorRect = %Dim
@onready var _map_blocker: ColorRect = %MapInputBlocker
@onready var _highlight: ColorRect = %HighlightBorder
@onready var _coach_panel: Panel = %CoachPanel
@onready var _coach_label: Label = %CoachLabel
@onready var _got_it_btn: Button = %GotItButton

var context: BattleContext = null
var _hud: BattleHudController = null
var _battle_root: Node2D = null
var _fate_draft: FateDraftController = null
var _step_index: int = 0
var _steps: Array[Dictionary] = []
var _waiting_for_action: bool = false
var _pending_init: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if _got_it_btn:
		_got_it_btn.pressed.connect(_on_got_it)
	if _coach_panel:
		_coach_panel.gui_input.connect(_on_coach_panel_gui_input)
	if _root:
		_root.gui_input.connect(_on_root_gui_input)
	if not _pending_init.is_empty():
		_begin_tutorial()


func _input(event: InputEvent) -> void:
	if context == null or not context.tutorial_active:
		return
	if _step_index >= _steps.size():
		return
	if not _is_got_it_press(event):
		return
	var step: Dictionary = _steps[_step_index]
	var screen_pos := _event_screen_pos(event)
	if not should_swallow_playfield_press(step, screen_pos):
		return
	get_viewport().set_input_as_handled()


func should_swallow_playfield_press(step: Dictionary, screen_pos: Vector2) -> bool:
	var allowed: Array = step.get("allowed", [])
	if allowed.has("battlefield"):
		return false
	var allows_map_interaction: bool = allowed.has("battlefield") or allowed.has("build_pads")
	if allows_map_interaction:
		return false
	var active_gated: bool = not bool(step.get("pause", true)) and not allows_map_interaction
	if not active_gated:
		return false
	if not _is_in_playfield(screen_pos):
		return false
	if _is_in_allowed_hud_rect(screen_pos, allowed):
		return false
	return true


func _is_in_playfield(screen_pos: Vector2) -> bool:
	return screen_pos.y >= PLAYFIELD_TOP and screen_pos.y <= PLAYFIELD_BOTTOM


func _is_in_allowed_hud_rect(screen_pos: Vector2, allowed: Array) -> bool:
	if _hud == null:
		return false
	for key in allowed:
		var target := _hud.get_highlight_target(str(key))
		if target and target.get_global_rect().has_point(screen_pos):
			return true
	return false


func initialize(
	ctx: BattleContext,
	hud: BattleHudController,
	battle_root: Node2D,
	fate_draft: FateDraftController
) -> void:
	_pending_init = {
		"context": ctx,
		"hud": hud,
		"battle_root": battle_root,
		"fate_draft": fate_draft,
	}
	if is_node_ready():
		_begin_tutorial()
	else:
		call_deferred("_begin_tutorial")


func _begin_tutorial() -> void:
	if _pending_init.is_empty():
		return
	context = _pending_init.get("context") as BattleContext
	_hud = _pending_init.get("hud") as BattleHudController
	_battle_root = _pending_init.get("battle_root") as Node2D
	_fate_draft = _pending_init.get("fate_draft") as FateDraftController
	_pending_init.clear()
	if context:
		context.tutorial_hold_waves = true
		context.tutorial_active = true
		context.runtime_modifiers["tutorial_block_victory"] = true
	_set_debug_menu_visible(false)
	_steps = _build_steps()
	_connect_events()
	_show_step(0)


func _build_steps() -> Array[Dictionary]:
	return [
		{
			"id": "welcome",
			"text": "Welcome, champion. Defend the Sacred Fire, scavenge Star Iron, and push back corruption before it claims your towers.\n\nTap Got it to begin.",
			"highlight": "",
			"advance": StepAdvance.GOT_IT,
			"pause": true,
			"allowed": [],
		},
		{
			"id": "read_battlefield",
			"text": "Enemies march along the path toward your Gate. Stop leaks before your Lives reach zero.",
			"highlight": "battlefield",
			"advance": StepAdvance.GOT_IT,
			"pause": true,
			"allowed": [],
		},
		{
			"id": "tower_families",
			"text": "Four tower families: Archer (steady DPS), Sacred Fire (burn), Heavy (armor break), Control (slow). Tap beside the road to build.",
			"highlight": "build_pads",
			"advance": StepAdvance.GOT_IT,
			"pause": true,
			"allowed": [],
		},
		{
			"id": "place_tower",
			"text": "Tap beside the road and pick a tower from the radial menu.",
			"highlight": "build_pads",
			"advance": StepAdvance.TOWER_BUILT,
			"pause": false,
			"allowed": ["build_pads", "battlefield"],
		},
		{
			"id": "gold_economy",
			"text": "Gold (top bar) pays for towers on build pads only. It is separate from Star Iron materials you scavenge in battle.",
			"highlight": "gold",
			"advance": StepAdvance.GOT_IT,
			"pause": true,
			"allowed": [],
		},
		{
			"id": "start_wave",
			"text": "When ready, press Start Wave to begin the assault.",
			"highlight": "start_wave",
			"advance": StepAdvance.WAVE_STARTED,
			"pause": false,
			"allowed": ["start_wave", "battlefield"],
		},
		{
			"id": "lives_gate",
			"text": "Each enemy that reaches the Gate costs a Life. At zero Lives, the battle is lost.",
			"highlight": "lives",
			"advance": StepAdvance.GOT_IT,
			"pause": true,
			"allowed": [],
		},
		{
			"id": "objective",
			"text": "Each Labour has a bonus objective. Labour 1: let no enemy reach the Gate.",
			"highlight": "lives",
			"advance": StepAdvance.GOT_IT,
			"pause": true,
			"allowed": [],
		},
		{
			"id": "morale",
			"text": "Morale rises as you fight well and boosts your towers; it falls when enemies leak.",
			"highlight": "morale",
			"advance": StepAdvance.GOT_IT,
			"pause": true,
			"allowed": [],
		},
		{
			"id": "pause_speed",
			"text": "Pause to plan your defense. Use 2x speed when you are comfortable with the flow.",
			"highlight": "pause_speed",
			"advance": StepAdvance.GOT_IT,
			"pause": true,
			"allowed": [],
		},
		{
			"id": "move_hero",
			"text": "Hold the left stick to move Rostam. Block the path, collect Star Iron, and dodge enemy swings.",
			"highlight": "joystick",
			"advance": StepAdvance.HERO_MOVED,
			"pause": false,
			"allowed": ["battlefield"],
		},
		{
			"id": "hero_attack",
			"text": "Tap Attack to strike foes in front of you. Heavy Attack hits harder with a short wind-up.",
			"highlight": "attack",
			"advance": StepAdvance.HERO_ATTACK,
			"pause": false,
			"allowed": ["battlefield"],
		},
		{
			"id": "hero_dodge",
			"text": "Tap Dodge to roll away with brief invulnerability — use it when enemies flash red before a swing.",
			"highlight": "dodge",
			"advance": StepAdvance.HERO_DODGE,
			"pause": false,
			"allowed": ["battlefield"],
		},
		{
			"id": "scavenge_star_iron",
			"text": "Enemies can drop glowing Star Iron on the path. Walk Rostam over a drop to collect it into your unbanked tally (watch the Materials line). Drops vanish after 10 seconds.",
			"highlight": "materials",
			"advance": StepAdvance.MATERIAL_COLLECTED,
			"pause": false,
			"allowed": ["battlefield"],
			"on_enter": "_lesson_spawn_tutorial_drop",
		},
		{
			"id": "bank_materials",
			"text": "Unbanked materials are risky: you lose them all if Lives hit zero. Clear the battle or use Retreat to Forge at Pardeh to bank Star Iron into Kaveh's Forge for tower unlocks and upgrades.",
			"highlight": "materials",
			"advance": StepAdvance.GOT_IT,
			"pause": true,
			"allowed": [],
		},
		{
			"id": "hero_skill",
			"text": "Press Skill for Rostam's area charge — your big cooldown ability.",
			"highlight": "skill",
			"advance": StepAdvance.HERO_SKILL,
			"pause": false,
			"allowed": ["skill", "battlefield"],
		},
		{
			"id": "corruption",
			"text": "Corruption weakens regions: Stable → Pressured → Critical → Collapsed. Watch regional light fall.",
			"highlight": "sacred_fire",
			"advance": StepAdvance.GOT_IT,
			"pause": true,
			"allowed": [],
			"on_enter": "_lesson_corruption_pressure",
		},
		{
			"id": "cleanse",
			"text": "Spend Sacred Fire to Cleanse a region and restore its light.",
			"highlight": "cleanse",
			"advance": StepAdvance.CLEANSE,
			"pause": false,
			"allowed": ["cleanse", "battlefield"],
		},
		{
			"id": "hijack",
			"text": "At zero light, towers can be hijacked! Cleanse the region to rescue your tower.",
			"highlight": "cleanse",
			"advance": StepAdvance.HIJACK_RECOVERED,
			"pause": false,
			"allowed": ["cleanse", "battlefield"],
			"on_enter": "_lesson_hijack_collapse",
		},
		{
			"id": "fate_cards",
			"text": "Pardeh Break: choose one double-edged Fate card. Boon and curse both apply. In real battles you can also Retreat to Forge here to bank scavenged Star Iron and exit safely.",
			"highlight": "",
			"advance": StepAdvance.FATE_SELECTED,
			"pause": true,
			"allowed": ["fate_draft"],
			"on_enter": "_lesson_pardeh_break",
		},
		{
			"id": "boss_warning",
			"text": "The final wave brings a boss with telegraphed attacks. Pause, focus fire, and use Rostam.",
			"highlight": "",
			"advance": StepAdvance.GOT_IT,
			"pause": true,
			"allowed": [],
		},
		{
			"id": "survive",
			"text": "Clear the remaining enemies to complete your training.",
			"highlight": "",
			"advance": StepAdvance.VICTORY,
			"pause": false,
			"allowed": ["battlefield"],
			"on_enter": "_lesson_release_victory",
		},
		{
			"id": "complete",
			"text": "Training complete! On the world map: play linear Labours 1–7, or start a Campaign Run (draft 3 towers, branch through skirmishes, bank materials at Kaveh's Forge). Replay anytime to practice.",
			"highlight": "",
			"advance": StepAdvance.GOT_IT,
			"pause": true,
			"allowed": [],
			"on_enter": "_lesson_mark_complete",
		},
	]


func _connect_events() -> void:
	CombatEvents.tower_built.connect(_on_tower_built)
	CombatEvents.wave_started.connect(_on_wave_started)
	CombatEvents.hero_moved.connect(_on_hero_moved)
	CombatEvents.hero_melee_used.connect(_on_hero_melee_used)
	CombatEvents.hero_dodged.connect(_on_hero_dodged)
	CombatEvents.hero_skill_used.connect(_on_hero_skill_used)
	CombatEvents.cleanse_used.connect(_on_cleanse_used)
	CombatEvents.tower_hijack_recovered.connect(_on_hijack_recovered)
	CombatEvents.fate_card_selected.connect(_on_fate_selected)
	CombatEvents.battle_completed.connect(_on_battle_completed)
	if context and context.bridge:
		context.bridge.materials_changed.connect(_on_materials_changed)


func _show_step(index: int) -> void:
	if index >= _steps.size():
		return
	_step_index = index
	var step: Dictionary = _steps[index]
	_waiting_for_action = step.advance != StepAdvance.GOT_IT
	_update_coach(step.text)
	_update_highlight(step.get("highlight", ""))
	if step.get("pause", true):
		_pause_battle()
	else:
		_resume_battle()
	if step.has("on_enter"):
		var method_name: String = step.on_enter
		if has_method(method_name):
			call(method_name)
	if step.advance == StepAdvance.GOT_IT and _got_it_btn:
		_got_it_btn.visible = true
	elif _got_it_btn:
		_got_it_btn.visible = false
	_update_dim_for_step(step)
	_apply_gating(step.get("allowed", []))
	if context and context.hero_manager and not step.get("allowed", []).has("battlefield"):
		context.hero_manager.cancel_hero_move()


func _update_dim_for_step(step: Dictionary) -> void:
	if _dim == null:
		return
	var allowed: Array = step.get("allowed", [])
	var allows_fate_draft: bool = allowed.has("fate_draft")
	if allows_fate_draft:
		if _dim:
			_dim.visible = false
		if _root:
			_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if _coach_panel:
			_coach_panel.visible = false
			_coach_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if _map_blocker:
			_map_blocker.mouse_filter = Control.MOUSE_FILTER_IGNORE
		return
	var needs_map: bool = step.advance in [
		StepAdvance.TOWER_BUILT,
		StepAdvance.HERO_MOVED,
		StepAdvance.HERO_ATTACK,
		StepAdvance.HERO_DODGE,
		StepAdvance.MATERIAL_COLLECTED,
	]
	_dim.visible = not needs_map
	_dim.color.a = DIM_ALPHA_MAP if needs_map else DIM_ALPHA_COACH
	var block_hud: bool = _dim.visible and step.get("pause", true)
	var allows_battlefield: bool = allowed.has("battlefield")
	var allows_map_interaction: bool = allows_battlefield or allowed.has("build_pads")
	if _root:
		if allows_battlefield:
			_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
		else:
			_root.mouse_filter = Control.MOUSE_FILTER_STOP if block_hud else Control.MOUSE_FILTER_IGNORE
	if _coach_panel:
		_coach_panel.visible = true
		_coach_panel.mouse_filter = (
			Control.MOUSE_FILTER_IGNORE if allows_map_interaction else Control.MOUSE_FILTER_STOP
		)
		_apply_coach_layout(allows_map_interaction)
	var active_gated: bool = not bool(step.get("pause", true)) and not allows_map_interaction
	if _map_blocker:
		_map_blocker.mouse_filter = (
			Control.MOUSE_FILTER_STOP if active_gated and not block_hud else Control.MOUSE_FILTER_IGNORE
		)


func _apply_coach_layout(bottom: bool) -> void:
	if _coach_panel == null:
		return
	var layout: Dictionary = COACH_BOTTOM if bottom else COACH_CENTER
	_coach_panel.set_anchors_preset(Control.PRESET_CENTER)
	_coach_panel.offset_left = layout.left
	_coach_panel.offset_top = layout.top
	_coach_panel.offset_right = layout.right
	_coach_panel.offset_bottom = layout.bottom


func _advance_step() -> void:
	var next := _step_index + 1
	if next >= _steps.size():
		_hide_overlay()
		return
	_show_step(next)


func _on_got_it() -> void:
	_advance_got_it_step()


func _advance_got_it_step() -> void:
	if _step_index >= _steps.size():
		return
	var step: Dictionary = _steps[_step_index]
	if step.advance != StepAdvance.GOT_IT:
		return
	_advance_step()


func _on_coach_panel_gui_input(event: InputEvent) -> void:
	if not _is_got_it_press(event):
		return
	_advance_got_it_step()


func _on_root_gui_input(event: InputEvent) -> void:
	if _step_index >= _steps.size():
		return
	var step: Dictionary = _steps[_step_index]
	if step.advance != StepAdvance.GOT_IT:
		return
	if not _is_got_it_press(event):
		return
	if _coach_panel and _coach_panel.get_global_rect().has_point(_event_screen_pos(event)):
		return
	_advance_got_it_step()


func _is_got_it_press(event: InputEvent) -> bool:
	if event is InputEventScreenTouch:
		return event.pressed
	if event is InputEventMouseButton:
		return event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	return false


func _event_screen_pos(event: InputEvent) -> Vector2:
	if event is InputEventScreenTouch:
		return event.position
	if event is InputEventMouseButton:
		return event.position
	return Vector2.ZERO


func _on_tower_built(_tower_id: String) -> void:
	_try_advance(StepAdvance.TOWER_BUILT)


func _on_wave_started(_wave_index: int) -> void:
	_try_advance(StepAdvance.WAVE_STARTED)


func _on_hero_moved() -> void:
	_try_advance(StepAdvance.HERO_MOVED)


func _on_hero_melee_used(action_id: String) -> void:
	if action_id == "attack":
		_try_advance(StepAdvance.HERO_ATTACK)
	elif action_id == "heavy":
		_try_advance(StepAdvance.HERO_ATTACK)


func _on_hero_dodged() -> void:
	_try_advance(StepAdvance.HERO_DODGE)


func _on_hero_skill_used(_skill_id: String) -> void:
	_try_advance(StepAdvance.HERO_SKILL)


func _on_cleanse_used(_region_id: String) -> void:
	_try_advance(StepAdvance.CLEANSE)


func _on_hijack_recovered(_spot_id: String) -> void:
	_try_advance(StepAdvance.HIJACK_RECOVERED)


func _on_fate_selected(_card_id: String) -> void:
	_try_advance(StepAdvance.FATE_SELECTED)


func _on_battle_completed(victory: bool, _level_id: String) -> void:
	if victory:
		_try_advance(StepAdvance.VICTORY)


func _on_materials_changed(unbanked: Dictionary) -> void:
	if not unbanked.is_empty():
		_try_advance(StepAdvance.MATERIAL_COLLECTED)


func _try_advance(expected: StepAdvance) -> void:
	if _step_index >= _steps.size():
		return
	var step: Dictionary = _steps[_step_index]
	if step.advance != expected:
		return
	_advance_step()


func _update_coach(text: String) -> void:
	if _coach_label:
		_coach_label.text = text
	if _coach_panel:
		_coach_panel.visible = true
	_set_overlay_visible(true)


func _update_highlight(key: String) -> void:
	if _highlight == null:
		return
	if key.is_empty():
		_highlight.visible = false
		return
	if key == "battlefield" and _battle_root:
		var gate := _battle_root.get_node_or_null("MapRoot/Gate") as Node2D
		if gate:
			var screen_pos := _battle_root.get_viewport().get_canvas_transform() * gate.global_position
			_highlight.global_position = screen_pos - Vector2(200, 80)
			_highlight.size = Vector2(400, 160)
			_highlight.visible = true
			return
	if key == "build_pads" and _battle_root and context and context.level_data:
		var pts := context.level_data.get_all_route_points()
		if pts.size() >= 2:
			var mid := pts[pts.size() / 2]
			var hint_pos := mid + Vector2(0, -60)
			var screen_pos := BattleUiCoords.world_to_screen(_battle_root.get_viewport(), hint_pos)
			_highlight.global_position = screen_pos - Vector2(36, 36)
			_highlight.size = Vector2(72, 72)
			_highlight.visible = true
			return
	var target := _resolve_highlight_target(key)
	if target == null:
		_highlight.visible = false
		return
	var rect := target.get_global_rect()
	_highlight.global_position = rect.position - Vector2(4, 4)
	_highlight.size = rect.size + Vector2(8, 8)
	_highlight.visible = true


func _resolve_highlight_target(key: String) -> Control:
	if _hud:
		var hud_target := _hud.get_highlight_target(key)
		if hud_target:
			return hud_target
	return null


func _pause_battle() -> void:
	if context and context.state_controller:
		if context.state_controller.current_state == GameEnums.BattleState.WAVE_ACTIVE:
			context.state_controller.pause_battle()


func _resume_battle() -> void:
	if context and context.state_controller:
		if context.state_controller.current_state == GameEnums.BattleState.PAUSED:
			context.state_controller.resume_battle()
		elif context.state_controller.current_state == GameEnums.BattleState.WAVE_ACTIVE:
			Engine.time_scale = context.state_controller.speed_multiplier


func _apply_gating(allowed: Array) -> void:
	if context:
		context.set_tutorial_allowed(allowed)
	if _hud:
		_hud.apply_tutorial_gating(PackedStringArray(allowed))


func _set_debug_menu_visible(show_menu: bool) -> void:
	for node in get_tree().get_nodes_in_group("debug_menu"):
		if node is CanvasLayer:
			node.visible = show_menu and OS.is_debug_build()


func _hide_overlay() -> void:
	_set_overlay_visible(false)
	if context:
		context.tutorial_active = false
		context.set_tutorial_allowed([])
	if _hud:
		_hud.clear_tutorial_gating()
	_set_debug_menu_visible(true)
	if _coach_panel:
		_coach_panel.visible = false
	if _highlight:
		_highlight.visible = false
	if _dim:
		_dim.visible = false
	if _root:
		_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_resume_battle()


func _set_overlay_visible(show_overlay: bool) -> void:
	visible = show_overlay


func _get_tower_region_id() -> String:
	if context == null or context.tower_manager == null:
		return "region_north"
	for t in context.tower_manager.towers:
		if t and t.region_id != "":
			return t.region_id
	if context.level_data and context.level_data.region_ids.size() > 0:
		return context.level_data.region_ids[0]
	return "region_north"


func _lesson_spawn_tutorial_drop() -> void:
	if context == null or context.loot_drops == null:
		return
	var drop_pos := Vector2(480, 320)
	if context.hero_manager and context.hero_manager.hero:
		drop_pos = context.hero_manager.hero.global_position + Vector2(56, 0)
	context.loot_drops.spawn_guaranteed_drop(drop_pos, "iron_falcon", 2)


func _lesson_corruption_pressure() -> void:
	if context and context.map_light:
		context.map_light.apply_corruption_pressure(_get_tower_region_id(), 35.0)


func _lesson_hijack_collapse() -> void:
	if context and context.map_light:
		var region_id := _get_tower_region_id()
		context.map_light.apply_corruption_pressure(region_id, 100.0)
		for t in context.tower_manager.towers if context.tower_manager else []:
			if t and t.region_id == region_id:
				t.on_region_light_changed(0)


func _lesson_pardeh_break() -> void:
	_pause_battle()
	if _fate_draft:
		_fate_draft.show_draft()
	elif context and context.bridge:
		context.bridge.pardeh_break_requested.emit()


func _lesson_release_victory() -> void:
	if context:
		context.runtime_modifiers["tutorial_block_victory"] = false
		context.tutorial_hold_waves = false
	_resume_battle()
	if context and context.wave_manager:
		context.wave_manager.continue_after_tutorial_hold()
	if context and context.state_controller:
		context.state_controller._check_victory()


func _lesson_mark_complete() -> void:
	if SaveSystem:
		SaveSystem.mark_tutorial_completed()


func _exit_tree() -> void:
	if Engine.time_scale == 0.0:
		Engine.time_scale = 1.0
