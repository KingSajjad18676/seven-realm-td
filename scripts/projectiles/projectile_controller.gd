class_name ProjectileController
extends Node2D

signal hit_target

var _target: EnemyController = null
var _speed: float = 300.0
var _alive: bool = false

@onready var _sprite: ColorRect = $Sprite


func launch(from: Vector2, target: EnemyController, speed: float, color: Color) -> void:
	global_position = from
	_target = target
	_speed = speed
	_alive = true
	if _sprite:
		_sprite.color = color
		_sprite.size = Vector2(8, 8)
		_sprite.position = Vector2(-4, -4)


func _process(delta: float) -> void:
	if not _alive or _target == null or not is_instance_valid(_target):
		_alive = false
		hit_target.emit()
		return
	var dir := (_target.global_position - global_position).normalized()
	global_position += dir * _speed * delta
	if global_position.distance_to(_target.global_position) < 12.0:
		_alive = false
		hit_target.emit()
