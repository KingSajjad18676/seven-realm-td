class_name CompanionManager
extends Node

var context: BattleContext = null
var _entity: CompanionEntity = null
var _cheetah: CheetahScavengerBehavior = null
var _simurgh: SimurghOrbiterBehavior = null
var _zavareh: ZavarehGateGuardBehavior = null
var _companion_scene: PackedScene = preload("res://scenes/prefabs/companion.tscn")


func initialize(ctx: BattleContext, units_root: Node2D) -> void:
	context = ctx
	var companion_id := ""
	if ctx.launch_data:
		companion_id = ctx.launch_data.active_companion_id
	if companion_id == "":
		return
	var data := ContentRegistry.get_companion(companion_id) if ContentRegistry else null
	if data == null or not data.is_shrine_pick():
		return
	_spawn_companion(units_root, data)


func _spawn_companion(root: Node2D, data: CompanionData) -> void:
	if _companion_scene == null:
		return
	_entity = _companion_scene.instantiate() as CompanionEntity
	if _entity == null:
		return
	root.add_child(_entity)
	_entity.setup(context, data)
	var hero := context.hero_manager.hero if context.hero_manager else null
	if hero:
		_entity.global_position = hero.global_position + Vector2(40, 0)
	match data.behavior:
		CompanionData.Behavior.CHEETAH_SCAVENGER:
			_cheetah = CheetahScavengerBehavior.new()
			_cheetah.bind(_entity, context, data)
		CompanionData.Behavior.SIMURGH_ORBITER:
			_simurgh = SimurghOrbiterBehavior.new()
			_simurgh.bind(_entity, context, data)
		CompanionData.Behavior.ZAVAREH_GATE_GUARD:
			_zavareh = ZavarehGateGuardBehavior.new()
			_zavareh.bind(_entity, context, data)
	if context.bridge:
		context.bridge.alert_message.emit("Companion joined: %s" % data.display_name, 55)


func _physics_process(delta: float) -> void:
	if _cheetah:
		_cheetah.tick(delta)
	elif _simurgh:
		_simurgh.tick(delta)
	elif _zavareh:
		_zavareh.tick(delta)
