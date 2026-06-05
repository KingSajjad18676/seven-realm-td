class_name TowerData
extends Resource

@export_group("Identity")
@export var tower_id: String = ""
@export var display_name: String = ""
@export var family: GameEnums.TowerFamily = GameEnums.TowerFamily.ARCHER

@export_group("Economy")
@export var build_cost: int = 50
@export var upgrade_cost: int = 40
@export var sell_refund_ratio: float = 0.6
@export var max_level: int = 3

@export_group("Combat")
@export var range: float = 140.0
@export var attack_rate: float = 1.0
@export var damage: float = 12.0
@export var projectile_speed: float = 320.0
@export var target_mode: GameEnums.TargetMode = GameEnums.TargetMode.FIRST
@export var applies_burn: bool = false
@export var applies_slow: bool = false
@export var armor_break: bool = false
@export var color: Color = Color.WHITE
@export var attack_behavior: GameEnums.AttackBehavior = GameEnums.AttackBehavior.SINGLE

@export_group("Barracks")
@export var spawn_unit_id: String = ""
@export var upgraded_unit_id: String = ""
@export var max_units: int = 2
@export var unit_respawn_cooldown: float = 5.0
@export var rally_offset: Vector2 = Vector2(0, -40)

@export_group("Forge")
## Unique Star Iron ID; non-empty registers tower in Kaveh's Forge (see prompts/10-add-new-content.prompt.md).
@export var forge_material_id: String = ""
@export var forge_material_name: String = ""

@export_group("Scene")
@export var scene_path: String = "res://scenes/prefabs/tower.tscn"
@export var sprite_path: String = ""
