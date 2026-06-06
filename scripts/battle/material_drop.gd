class_name MaterialDrop
extends Area2D

const DESPAWN_SECONDS := 10.0

var material_id: String = ""
var amount: int = 1
var _collected: bool = false
var _manager: LootDropManager = null

@onready var _sprite: ColorRect = $Sprite
@onready var _timer: Timer = $DespawnTimer


func initialize(mat_id: String, amt: int, manager: LootDropManager) -> void:
	material_id = mat_id
	amount = maxi(1, amt)
	_manager = manager
	_collected = false
	_ensure_wired()
	if _sprite:
		_sprite.color = _color_for_material(mat_id)
	if _timer:
		_timer.wait_time = DESPAWN_SECONDS
		_timer.start()


func _ready() -> void:
	_ensure_wired()


func _ensure_wired() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if _timer and not _timer.timeout.is_connected(_on_despawn_timeout):
		_timer.timeout.connect(_on_despawn_timeout)


func can_collect(collector: Node2D) -> bool:
	if _collected or collector == null:
		return false
	if collector is HeroController:
		return true
	if collector.has_method("collects_material_drops"):
		return bool(collector.call("collects_material_drops"))
	return false


func _on_body_entered(body: Node2D) -> void:
	if _collected or not can_collect(body):
		return
	if body is HeroController:
		collect(body as HeroController)
	elif body.has_method("collects_material_drops") and body.collects_material_drops():
		collect_to_cargo(body)


func collect(_hero: HeroController) -> void:
	if _collected:
		return
	_collected = true
	if _manager:
		_manager.on_drop_collected(self, _hero)
	despawn()


func collect_to_cargo(_collector: Node2D) -> Dictionary:
	if _collected:
		return {}
	_collected = true
	var payload := {material_id: amount}
	if _manager:
		_manager.on_drop_despawned(self)
	despawn()
	return payload


func despawn() -> void:
	if _manager and not _collected:
		_manager.on_drop_despawned(self)
	queue_free()


func _on_despawn_timeout() -> void:
	if not _collected:
		despawn()


func _color_for_material(mat_id: String) -> Color:
	match mat_id:
		"iron_falcon":
			return Color(0.75, 0.85, 0.95)
		"iron_ember":
			return Color(1.0, 0.55, 0.2)
		"iron_anvil":
			return Color(0.55, 0.5, 0.45)
		"iron_frost":
			return Color(0.45, 0.65, 0.95)
		"iron_serpent":
			return Color(0.35, 0.75, 0.45)
		"iron_volcano":
			return Color(0.9, 0.35, 0.15)
		_:
			return Color(0.85, 0.75, 0.35)
