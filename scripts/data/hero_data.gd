class_name HeroData
extends Resource

@export var hero_id: String = ""
@export var display_name: String = ""
@export var max_hp: float = 200.0
@export var move_speed: float = 180.0
@export var attack_damage: float = 25.0
@export var attack_rate: float = 1.2
@export var skill_id: String = "rostam_charge"
@export var skill_cooldown: float = 8.0
@export var skill_damage: float = 60.0
@export var tether_radius: float = 120.0
@export var color: Color = Color.DODGER_BLUE
@export var scene_path: String = "res://scenes/prefabs/hero.tscn"
@export var sprite_path: String = ""
