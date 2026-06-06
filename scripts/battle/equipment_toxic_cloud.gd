class_name EquipmentToxicCloud
extends Area2D

var context: BattleContext = null
var _duration: float = 0.0
var _radius: float = 90.0


func setup(ctx: BattleContext, duration: float, radius: float) -> void:
	context = ctx
	_duration = duration
	_radius = radius
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = radius
	shape.shape = circle
	add_child(shape)
	monitoring = true
	monitorable = false
	collision_layer = 0
	collision_mask = 0
	z_index = 5


func _process(delta: float) -> void:
	_duration -= delta
	if _duration <= 0.0:
		queue_free()
		return
	if context == null:
		return
	for e in context.active_enemies:
		if not e is EnemyController:
			continue
		var enemy: EnemyController = e
		if global_position.distance_to(enemy.global_position) <= _radius:
			enemy.apply_slow(0.0, 0.25)
