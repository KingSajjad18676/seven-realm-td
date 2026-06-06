class_name CompanionData
extends Resource

enum Behavior {
	RAKHSH_MOUNT,
	CHEETAH_SCAVENGER,
	SIMURGH_ORBITER,
	ZAVAREH_GATE_GUARD,
}

@export var companion_id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var behavior: Behavior = Behavior.CHEETAH_SCAVENGER
@export var move_speed: float = 200.0
@export var orbit_radius: float = 70.0
@export var orbit_speed: float = 0.8
@export var pulse_interval_sec: float = 15.0
@export var pulse_light_amount: int = 50
@export var gate_offset: Vector2 = Vector2(-55, 0)
@export var max_hp: float = 240.0
@export var attack_damage: float = 24.0
@export var attack_rate: float = 0.85
@export var mount_stand_sec: float = 1.0
@export var mount_speed_mult: float = 3.0
@export var knockback_distance: float = 28.0
@export var knockback_radius: float = 35.0
@export var bank_radius: float = 48.0
@export var color: Color = Color(0.85, 0.7, 0.35)
@export var sprite_path: String = ""


func is_shrine_pick() -> bool:
	return behavior != Behavior.RAKHSH_MOUNT
