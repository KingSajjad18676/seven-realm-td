class_name LevelData
extends Resource

@export var level_id: String = ""
@export var display_name: String = ""
@export var grid_width: int = 32
@export var grid_height: int = 18
@export var starting_gold: int = 120
@export var starting_lives: int = 20
@export var starting_sacred_fire: int = 3
@export var waves: Array[WaveData] = []
@export var available_tower_ids: Array[String] = []
@export var hero_id: String = "rostam"
@export var build_spot_positions: Array[Vector2] = []
@export var path_points: Array[Vector2] = []
@export var gate_position: Vector2 = Vector2.ZERO
@export var spawn_position: Vector2 = Vector2.ZERO
@export var region_ids: Array[String] = []
@export var is_tutorial: bool = false
@export var map_sprite_path: String = ""
@export var camera_anchors: Array[Vector2] = []
@export var uses_large_map_camera: bool = false
@export var minimap_bounds: Rect2 = Rect2(0, 0, 1280, 720)
@export var boss_enemy_id: String = ""
@export var default_objective_id: String = ""
