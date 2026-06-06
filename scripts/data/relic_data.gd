class_name RelicData
extends Resource

@export var relic_id: String = ""
@export var title: String = ""
@export var description: String = ""
@export var slot_tower_id: String = ""
@export var global_targeting: bool = false
@export var tower_attack_rate_mult: float = 1.0
@export var tower_damage_mult: float = 1.0
@export var gate_lives_per_attack: float = 0.0
@export var attack_mult: float = 1.0
@export var gold_bonus_per_wave: int = 0
@export var sacred_fire_bonus: int = 0
@export var morale_bonus: int = 0
@export var corruption_resist: float = 0.0


func is_tower_relic() -> bool:
	return slot_tower_id != ""


func is_global_relic() -> bool:
	return slot_tower_id == ""
