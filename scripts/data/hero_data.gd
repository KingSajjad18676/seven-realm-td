class_name HeroData
extends Resource

@export var hero_id: String = ""
@export var display_name: String = ""
@export var max_hp: float = 200.0
@export var move_speed: float = 180.0
@export var attack_damage: float = 25.0
@export var attack_rate: float = 1.2
@export var attack_arc_range: float = 62.0
@export var attack_arc_degrees: float = 110.0
@export var attack_max_targets: int = 3
@export var heavy_damage: float = 48.0
@export var heavy_cooldown: float = 5.0
@export var heavy_radius: float = 78.0
@export var dodge_cooldown: float = 2.5
@export var dodge_distance: float = 95.0
@export var dodge_iframe_sec: float = 0.4
@export var skill_id: String = "rostam_charge"
@export var skill_cooldown: float = 8.0
@export var skill_damage: float = 60.0
@export var tether_radius: float = 120.0
@export var respawn_cooldown: float = 8.0
@export var color: Color = Color.DODGER_BLUE
@export var scene_path: String = "res://scenes/prefabs/hero.tscn"
@export var sprite_path: String = ""
@export var secondary_skill_id: String = ""
@export var naft_max_charges: int = 0
@export var naft_refill_sec: float = 20.0
@export var naft_max_active: int = 2
@export var naft_slick_half_length: float = 70.0
@export var naft_slow_mult: float = 0.35
@export var naft_oil_duration_sec: float = 35.0
@export var naft_blaze_duration_sec: float = 3.5
@export var naft_blaze_burst_damage: float = 40.0
@export var naft_blaze_dps: float = 22.0
