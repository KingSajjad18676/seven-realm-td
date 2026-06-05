class_name BattleContext
extends RefCounted

var level_data: LevelData = null
var launch_data: BattleLaunchData = null
var state_controller: BattleStateController = null
var wave_manager: WaveManager = null
var enemy_spawner: EnemySpawner = null
var economy: BattleEconomy = null
var lives: LivesController = null
var tower_manager: TowerManager = null
var hero_manager: HeroManager = null
var map_light: MapLightManager = null
var objectives: ObjectiveController = null
var morale: MoraleController = null
var run_modifiers: RunModifierService = null
var ancestral_forge: AncestralForgeController = null
var hunt: HuntController = null
var spell_controller: SpellController = null
var labour_mode: LabourMode = null
var bridge: BattleContextBridge = null
var run_summary: Dictionary = {}
var runtime_modifiers: Dictionary = {}
var selected_fate_card: FateCardData = null

var active_enemies: Array = []
var active_allies: Array = []
var path_points: PackedVector2Array = PackedVector2Array()
var tutorial_hold_waves: bool = false
var tutorial_active: bool = false
var tutorial_allowed: Dictionary = {}


func resolve_enemy_route(spawn_group: Dictionary) -> Dictionary:
	if level_data:
		return level_data.resolve_enemy_route(spawn_group)
	return {
		"spawn_id": "",
		"position": Vector2.ZERO,
		"route_id": "",
		"path": path_points,
	}


func set_tutorial_allowed(keys: Array) -> void:
	tutorial_allowed.clear()
	for key in keys:
		tutorial_allowed[str(key)] = true


func tutorial_allows(key: String) -> bool:
	if not tutorial_active:
		return true
	return bool(tutorial_allowed.get(key, false))
