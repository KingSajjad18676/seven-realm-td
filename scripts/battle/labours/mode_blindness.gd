extends LabourMode

const DARKNESS_INTERVAL := 14.0
const DARKNESS_INTERVAL_HIJACK := 10.0
const DARKNESS_DURATION := 6.0
var _darkness_timer := 0.0
var _darkness_active := false
var _darkness_remaining := 0.0
var _boss_defeated := false
var _boss_permanent_dark := false


func initialize(ctx: BattleContext) -> void:
	super.initialize(ctx)
	if context and context.bridge:
		context.bridge.alert_message.emit("Labour of the White Demon — darkness blinds the field", 70)


func _process(delta: float) -> void:
	if context == null or context.state_controller == null:
		return
	if context.state_controller.current_state != GameEnums.BattleState.WAVE_ACTIVE:
		return
	if _boss_defeated and not _boss_permanent_dark:
		return
	if _darkness_active:
		_darkness_remaining -= delta
		if _darkness_remaining <= 0.0 and not _boss_permanent_dark:
			_clear_darkness()
		return
	_darkness_timer += delta
	var interval := _darkness_interval()
	if _darkness_timer >= interval:
		_darkness_timer = 0.0
		_apply_darkness()


func _darkness_interval() -> float:
	if context == null or context.wave_manager == null:
		return DARKNESS_INTERVAL
	if is_hijack_phase(context.wave_manager.current_wave_index):
		return DARKNESS_INTERVAL_HIJACK
	return DARKNESS_INTERVAL


func _apply_darkness() -> void:
	_darkness_active = true
	_darkness_remaining = DARKNESS_DURATION if not _boss_permanent_dark else 999.0
	if context and context.runtime_modifiers:
		context.runtime_modifiers["tower_damage_mult"] = 0.75
		context.runtime_modifiers["vision_radius_mult"] = 0.7
	if context and context.bridge:
		context.bridge.alert_message.emit("Blinding sorcery — cleanse to push back the dark!", 50)


func _clear_darkness() -> void:
	_darkness_active = false
	if context and context.runtime_modifiers:
		context.runtime_modifiers.erase("tower_damage_mult")
		context.runtime_modifiers.erase("vision_radius_mult")


func on_boss_defeated() -> void:
	_boss_defeated = true
	_boss_permanent_dark = false
	_clear_darkness()
	if context and context.bridge:
		context.bridge.alert_message.emit("The White Demon's blood restores sight!", 70)


func on_cleanse(_region_id: String) -> void:
	if _boss_permanent_dark:
		_boss_permanent_dark = false
		_clear_darkness()
		if context and context.bridge:
			context.bridge.alert_message.emit("Sacred Fire breaks the White Div's darkness!", 70)
		return
	if _darkness_active:
		_darkness_remaining = maxf(0.0, _darkness_remaining - 2.0)
		if _darkness_remaining <= 0.0:
			_clear_darkness()


func set_boss_permanent_darkness(active: bool) -> void:
	_boss_permanent_dark = active
	if active:
		_apply_darkness()


func is_darkness_active() -> bool:
	return _darkness_active
