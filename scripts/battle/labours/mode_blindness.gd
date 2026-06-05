extends LabourMode

const DARKNESS_INTERVAL := 14.0
const DARKNESS_DURATION := 6.0
var _darkness_timer := 0.0
var _darkness_active := false
var _darkness_remaining := 0.0
var _boss_defeated := false


func initialize(ctx: BattleContext) -> void:
	super.initialize(ctx)
	if context and context.bridge:
		context.bridge.alert_message.emit("Labour of the White Demon — darkness blinds the field", 70)


func _process(delta: float) -> void:
	if context == null or context.state_controller == null:
		return
	if context.state_controller.current_state != GameEnums.BattleState.WAVE_ACTIVE:
		return
	if _boss_defeated:
		return
	if _darkness_active:
		_darkness_remaining -= delta
		if _darkness_remaining <= 0.0:
			_clear_darkness()
		return
	_darkness_timer += delta
	if _darkness_timer >= DARKNESS_INTERVAL:
		_darkness_timer = 0.0
		_apply_darkness()


func _apply_darkness() -> void:
	_darkness_active = true
	_darkness_remaining = DARKNESS_DURATION
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
	_clear_darkness()
	if context and context.bridge:
		context.bridge.alert_message.emit("The White Demon's blood restores sight!", 70)


func on_cleanse(_region_id: String) -> void:
	if _darkness_active:
		_darkness_remaining = maxf(0.0, _darkness_remaining - 2.0)
		if _darkness_remaining <= 0.0:
			_clear_darkness()
