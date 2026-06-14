class_name RakhshMountController
extends Node

const FOLLOW_OFFSET := Vector2(-30, 8)
const MOUNT_DISTANCE := 40.0
const MOUNTED_OFFSET := Vector2(-8, 0)

var context: BattleContext = null
var hero: HeroController = null
var mounted: bool = false
var _entity: CompanionEntity = null
var _companion_scene: PackedScene = preload("res://scenes/prefabs/companion.tscn")


func initialize(ctx: BattleContext, hero_node: HeroController, units_root: Node2D) -> void:
	context = ctx
	hero = hero_node
	if hero == null or hero.data == null or hero.data.hero_id != "rostam":
		return
	_spawn_rakhsh(units_root)


func _spawn_rakhsh(root: Node2D) -> void:
	if _companion_scene == null:
		return
	_entity = _companion_scene.instantiate() as CompanionEntity
	if _entity == null:
		return
	root.add_child(_entity)
	var data := CompanionData.new()
	data.companion_id = "companion_rakhsh"
	data.display_name = "Rakhsh"
	data.behavior = CompanionData.Behavior.RAKHSH_MOUNT
	data.color = Color(0.72, 0.42, 0.18)
	data.mount_speed_mult = 2.2
	data.knockback_distance = 28.0
	data.knockback_radius = 35.0
	_entity.setup(context, data)
	_entity.global_position = hero.global_position + FOLLOW_OFFSET


func is_mounted() -> bool:
	return mounted


func get_entity() -> CompanionEntity:
	return _entity


func is_within_mount_range() -> bool:
	if hero == null or _entity == null:
		return false
	return hero.global_position.distance_to(_entity.global_position) <= MOUNT_DISTANCE


func get_speed_mult() -> float:
	if not mounted or _entity == null:
		return 1.0
	return _entity.data.mount_speed_mult if _entity.data else 2.2


func mount() -> bool:
	if mounted or hero == null or _entity == null:
		return false
	if not _can_act():
		return false
	if not is_within_mount_range():
		if context and context.bridge:
			context.bridge.alert_message.emit("Too far from Rakhsh", 30)
		return false
	mounted = true
	_entity.global_position = hero.global_position + MOUNTED_OFFSET
	if context and context.bridge:
		context.bridge.alert_message.emit("Mounted Rakhsh!", 35)
	return true


func dismount(reason: String = "") -> void:
	if not mounted:
		return
	mounted = false
	if context and context.bridge and reason != "":
		context.bridge.alert_message.emit(reason, 30)


func toggle_mount() -> bool:
	if mounted:
		dismount("Dismounted")
		return true
	return mount()


func notify_hero_damaged() -> void:
	if mounted:
		dismount("Dismounted — Rostam struck!")


func _physics_process(delta: float) -> void:
	if hero == null or _entity == null or not is_instance_valid(hero):
		return
	if hero.is_dead() or not _can_act():
		return
	if not mounted:
		return
	_apply_knockback()
	if context and context.equipment_battle:
		EquipmentSetRules.on_mount_dash_through(context.equipment_battle, hero)
	_entity.global_position = hero.global_position + MOUNTED_OFFSET


func _can_act() -> bool:
	if context == null or context.state_controller == null:
		return false
	if context.state_controller.current_state == GameEnums.BattleState.WAVE_ACTIVE:
		return true
	return context.tutorial_active and context.tutorial_allows("battlefield")


func _apply_knockback() -> void:
	if context == null or _entity == null or _entity.data == null:
		return
	var radius := _entity.data.knockback_radius
	var knock := _entity.data.knockback_distance
	for e in context.active_enemies:
		if not e is EnemyController:
			continue
		var enemy: EnemyController = e
		if not enemy.has_tag("grunt"):
			continue
		if hero.global_position.distance_to(enemy.global_position) <= radius:
			enemy.apply_path_knockback(knock)
