class_name ObjectiveData
extends Resource

@export var objective_id: String = ""
@export var title: String = ""
@export var description: String = ""
@export var gold_reward: int = 25
@export var sacred_fire_reward: int = 1
@export var morale_reward: int = 10
## "no_leaks", "cleanse_twice", "no_hijack", or vow_* types
@export var goal_type: String = ""
@export var goal_count: int = 1
@export var is_vow: bool = false
@export var start_wave: int = 1
@export var end_wave: int = 0
@export var penalty_morale: int = 0
