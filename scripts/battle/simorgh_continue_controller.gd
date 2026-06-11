class_name SimorghContinueController
extends Node

signal continue_offered
signal continue_accepted
signal continue_declined

var context: BattleContext = null
var _ui: SimorghContinueModal = null
var _pending: bool = false


func initialize(ctx: BattleContext, ui: SimorghContinueModal) -> void:
	context = ctx
	_ui = ui
	if _ui:
		_ui.accepted.connect(_on_accepted)
		_ui.declined.connect(_on_declined)


func can_offer() -> bool:
	if context == null or context.launch_data == null:
		return false
	var launch := context.launch_data
	if launch.is_gauntlet_mode or launch.is_tutorial or launch.level_id == "level_00_tutorial":
		return false
	if launch.is_throne_defense_mode:
		return false
	if SaveSystem and SaveSystem.is_simorgh_feather_used_this_run():
		return false
	return true


func try_offer_continue() -> bool:
	if not can_offer() or _pending:
		return false
	_pending = true
	if context.state_controller:
		context.state_controller.pause_battle()
	if _ui:
		_ui.show_offer()
	continue_offered.emit()
	return true


func _on_accepted() -> void:
	if context == null:
		return
	if SaveSystem:
		SaveSystem.set_simorgh_feather_used()
	_clear_active_enemies()
	if context.lives:
		context.lives.max_lives = maxi(context.lives.max_lives, 3)
		context.lives.current_lives = 3
		context.lives._emit()
	if context.state_controller:
		context.state_controller.resume_battle()
	if context.bridge:
		context.bridge.alert_message.emit("Simorgh's Feather — the field is cleared!", 95)
	_pending = false
	continue_accepted.emit()


func _on_declined() -> void:
	_pending = false
	continue_declined.emit()
	if context and context.state_controller:
		var reason := "throne_breached" if (
			context.launch_data and context.launch_data.is_throne_defense_mode
		) else "lives_depleted"
		context.state_controller.trigger_defeat(reason)


func _clear_active_enemies() -> void:
	if context == null:
		return
	var copy := context.active_enemies.duplicate()
	for node in copy:
		if node is EnemyController and is_instance_valid(node):
			if context.enemy_spawner:
				context.enemy_spawner.release_enemy(node)
			else:
				node.queue_free()
	context.active_enemies.clear()
