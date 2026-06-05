class_name EnemyData
extends Resource

@export_group("Identity")
@export var enemy_id: String = ""
@export var display_name: String = ""
@export var tags: Array[String] = []

@export_group("Stats")
@export var max_hp: float = 30.0
@export var move_speed: float = 80.0
@export var armor: float = 0.0
@export var gold_reward: int = 8
@export var sacred_fire_reward: int = 0
@export var forge_material_id: String = ""
@export var forge_material_drop: int = 0
@export var corruption_pressure: float = 0.0
@export var is_boss: bool = false

@export_group("Visual")
@export var color: Color = Color.ORANGE_RED
@export var scale: float = 1.0
@export var sprite_path: String = ""

@export_group("Scene")
@export var scene_path: String = "res://scenes/prefabs/enemy.tscn"
