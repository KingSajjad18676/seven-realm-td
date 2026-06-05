class_name TutorialController
extends CanvasLayer

enum StepAdvance {
	GOT_IT,
	TOWER_BUILT,
	WAVE_STARTED,
	HERO_MOVED,
	HERO_SKILL,
	CLEANSE,
	HIJACK_RECOVERED,
	FATE_SELECTED,
	VICTORY,
}

@onready var _dim: ColorRect = %Dim
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


func initialize(
	ctx: BattleContext,
	hud: BattleHudController,
	battle_root: Node2D,
	fate_draft: FateDraftController
) -> void:
	context = ctx
	_hud = hud
	_battle_root = battle_root
	_fate_draft = fate_draft
	if ctx:
		ctx.tutorial_hold_waves = true
		ctx.runtime_modifiers["tutorial_block_victory"] = true
	_steps = _build_steps()
	_connect_events()
	if _got_it_btn:
		_got_it_btn.pressed.connect(_on_got_it)
	_show_step(0)


func _build_steps() -> Array[Dictionary]:
	return [
		{
			"id": "welcome",
			"text": "Welcome, champion. Defend the Sacred Fire and push back corruption before it claims your towers.",
			"highlight": "",
			"advance": StepAdvance.GOT_IT,
			"pause": true,
		},
		{
			"id": "read_battlefield",
			"text": "Enemies march along the path toward your Gate. Stop leaks before your Lives reach zero.",
			"highlight": "battlefield",
			"advance": StepAdvance.GOT_IT,
			"pause": true,
		},
		{
			"id": "tower_families",
			"text": "Four tower families: Archer (steady DPS), Sacred Fire (burn), Heavy (armor break), Control (slow). Each costs Gold.",
			"highlight": "tower_buttons",
			"advance": StepAdvance.GOT_IT,
			"pause": true,
		},
		{
			"id": "place_tower",
			"text": "Select a tower, then tap a green build pad to place it.",
			"highlight": "tower_buttons",
			"advance": StepAdvance.TOWER_BUILT,
			"pause": false,
		},
		{
			"id": "gold_economy",
			"text": "Defeating enemies earns Gold. Spend it to place more towers and hold the line.",
			"highlight": "gold",
			"advance": StepAdvance.GOT_IT,
			"pause": true,
		},
		{
			"id": "start_wave",
			"text": "When ready, press Start Wave to begin the assault.",
			"highlight": "start_wave",
			"advance": StepAdvance.WAVE_STARTED,
			"pause": false,
		},
		{
			"id": "lives_gate",
			"text": "Each enemy that reaches the Gate costs a Life. At zero Lives, the battle is lost.",
			"highlight": "lives",
			"advance": StepAdvance.GOT_IT,
			"pause": true,
		},
		{
			"id": "pause_speed",
			"text": "Pause to plan your defense. Use 2x speed when you are comfortable with the flow.",
			"highlight": "pause_speed",
			"advance": StepAdvance.GOT_IT,
			"pause": true,
		},
		{
			"id": "move_hero",
			"text": "Tap the battlefield to move Rostam. Use him to plug leaks and pressure elites.",
			"highlight": "",
			"advance": StepAdvance.HERO_MOVED,
			"pause": false,
		},
		{
			"id": "hero_skill",
			"text": "Press Rostam Skill for a powerful area strike on nearby foes.",
			"highlight": "skill",
			"advance": StepAdvance.HERO_SKILL,
			"pause": false,
		},
		{
			"id": "corruption",
			"text": "Corruption weakens regions: Stable → Pressured → Critical → Collapsed. Watch regional light fall.",
			"highlight": "sacred_fire",
			"advance": StepAdvance.GOT_IT,
			"pause": true,
			"on_enter": "_lesson_corruption_pressure",
		},
		{
			"id": "cleanse",
			"text": "Spend Sacred Fire to Cleanse a region and restore its light.",
			"highlight": "cleanse",
			"advance": StepAdvance.CLEANSE,
			"pause": false,
		},
		{
			"id": "hijack",
			"text": "At zero light, towers can be hijacked! Cleanse the region to rescue your tower.",
			"highlight": "cleanse",
			"advance": StepAdvance.HIJACK_RECOVERED,
			"pause": false,
			"on_enter": "_lesson_hijack_collapse",
		},
		{
			"id": "fate_cards",
			"text": "Pardeh Break: choose one double-edged Fate card. Boon and curse both apply.",
			"highlight": "",
			"advance": StepAdvance.FATE_SELECTED,
			"pause": true,
			"on_enter": "_lesson_pardeh_break",
		},
		{
			"id": "survive",
			"text": "Clear the remaining enemies to complete your training.",
			"highlight": "",
			"advance": StepAdvance.VICTORY,
			"pause": false,
			"on_enter": "_lesson_release_victory",
		},
		{
			"id": "complete",
			"text": "Training complete! Khan 1 awaits on the world map. Replay anytime to practice.",
			"highlight": "",
			"advance": StepAdvance.GOT_IT,
			"pause": true,
			"on_enter": "_lesson_mark_complete",
		},
	]


func _connect_events() -> void:
	CombatEvents.tower_built.connect(_on_tower_built)
	CombatEvents.wave_started.connect(_on_wave_started)
	CombatEvents.hero_moved.connect(_on_hero_moved)
	CombatEvents.hero_skill_used.connect(_on_hero_skill_used)
	CombatEvents.cleanse_used.connect(_on_cleanse_used)
	CombatEvents.tower_hijack_recovered.connect(_on_hijack_recovered)
	CombatEvents.fate_card_selected.connect(_on_fate_selected)
	CombatEvents.battle_completed.connect(_on_battle_completed)


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
	if _dim:
		var needs_map := step.advance in [
			StepAdvance.TOWER_BUILT,
			StepAdvance.HERO_MOVED,
		]
		_dim.visible = not needs_map
		_dim.color.a = 0.35 if needs_map else 0.55


func _advance_step() -> void:
	var next := _step_index + 1
	if next >= _steps.size():
		_hide_overlay()
		return
	_show_step(next)


func _on_got_it() -> void:
	var step: Dictionary = _steps[_step_index]
	if step.advance != StepAdvance.GOT_IT:
		return
	_advance_step()


func _on_tower_built(_tower_id: String) -> void:
	_try_advance(StepAdvance.TOWER_BUILT)


func _on_wave_started(_wave_index: int) -> void:
	_try_advance(StepAdvance.WAVE_STARTED)


func _on_hero_moved() -> void:
	_try_advance(StepAdvance.HERO_MOVED)


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
	visible = true


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
		elif context.state_controller.current_state == GameEnums.BattleState.PRE_BATTLE:
			Engine.time_scale = 0.0


func _resume_battle() -> void:
	if context and context.state_controller:
		if context.state_controller.current_state == GameEnums.BattleState.PAUSED:
			context.state_controller.resume_battle()
		elif context.state_controller.current_state == GameEnums.BattleState.PRE_BATTLE:
			Engine.time_scale = 1.0
		elif context.state_controller.current_state == GameEnums.BattleState.WAVE_ACTIVE:
			Engine.time_scale = context.state_controller.speed_multiplier


func _hide_overlay() -> void:
	visible = false
	if _coach_panel:
		_coach_panel.visible = false
	if _highlight:
		_highlight.visible = false
	_resume_battle()


func _get_tower_region_id() -> String:
	if context == null or context.tower_manager == null:
		return "region_north"
	for t in context.tower_manager.towers:
		if t and t.build_spot:
			return t.build_spot.region_id
	if context.level_data and context.level_data.region_ids.size() > 0:
		return context.level_data.region_ids[0]
	return "region_north"


func _lesson_corruption_pressure() -> void:
	if context and context.map_light:
		context.map_light.apply_corruption_pressure(_get_tower_region_id(), 35.0)


func _lesson_hijack_collapse() -> void:
	if context and context.map_light:
		var region_id := _get_tower_region_id()
		context.map_light.apply_corruption_pressure(region_id, 100.0)
		for t in context.tower_manager.towers if context.tower_manager else []:
			if t and t.build_spot and t.build_spot.region_id == region_id:
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
