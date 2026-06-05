extends LabourMode

const BURROW_INTERVAL := 12.0
var _burrow_timer := 0.0


func initialize(ctx: BattleContext) -> void:
	super.initialize(ctx)
	if context and context.bridge:
		context.bridge.alert_message.emit("Labour of the Dragon — Azhdaha strikes from shadow", 70)


func _process(delta: float) -> void:
	if context == null or context.state_controller == null:
		return
	if context.state_controller.current_state != GameEnums.BattleState.WAVE_ACTIVE:
		return
	_burrow_timer += delta
	if _burrow_timer >= BURROW_INTERVAL:
		_burrow_timer = 0.0
		_toggle_dragon_burrow()


func _toggle_dragon_burrow() -> void:
	if context == null:
		return
	var toggled := false
	for e in context.active_enemies:
		if e is EnemyController:
			var enemy: EnemyController = e
			if enemy.data and (enemy.data.tags.has("boss") or enemy.data.enemy_id.contains("serpent") or enemy.data.enemy_id.contains("azhdaha")):
				if enemy.is_burrowed():
					enemy.set_burrowed(false)
				else:
					enemy.set_burrowed(true)
				toggled = true
	if toggled and context.bridge:
		context.bridge.alert_message.emit("The dragon submerges — strike when it surfaces!", 40)
