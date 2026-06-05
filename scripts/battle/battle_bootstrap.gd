extends Node2D

@onready var _map_root: Node2D = $MapRoot
@onready var _path: Path2D = $MapRoot/Route
@onready var _gate: Node2D = $MapRoot/Gate
@onready var _spawn_marker: Node2D = $MapRoot/Spawn
@onready var _build_spots_root: Node2D = $MapRoot/BuildPads
@onready var _units_root: Node2D = $UnitsRoot
@onready var _towers_root: Node2D = $UnitsRoot/Towers
@onready var _projectiles_root: Node2D = $UnitsRoot/Projectiles
@onready var _heroes_root: Node2D = $UnitsRoot/Heroes
@onready var _camera: TouchCamera = $Camera2D
@onready var _hud: BattleHudController = $CanvasLayer
@onready var _pardeh_panel: Panel = $CanvasLayer/PardehPanel

var _context: BattleContext = null
var _bridge: BattleContextBridge = null
var _build_spot_scene: PackedScene = preload("res://scenes/prefabs/build_spot.tscn")
var _tutorial_overlay_scene: PackedScene = preload("res://scenes/ui/tutorial_overlay.tscn")


func _ready() -> void:
	add_to_group("battle_root")
	Engine.time_scale = 1.0
	_setup_battle()
	if OS.is_debug_build():
		var debug_scene := load("res://scenes/ui/debug_menu.tscn") as PackedScene
		if debug_scene:
			add_child(debug_scene.instantiate())
func _setup_battle() -> void:
	var launch := SceneFlowController.pending_launch
	if launch == null:
		launch = BattleLaunchData.new()
	var level := ContentRegistry.get_level(launch.level_id)
	if level == null:
		push_error("BattleBootstrap: missing level %s" % launch.level_id)
		return

	_context = BattleContext.new()
	_context.level_data = level
	_context.launch_data = launch
	_context.path_points = PackedVector2Array(level.path_points)

	_bridge = BattleContextBridge.new()
	_bridge.name = "BattleContextBridge"
	_bridge.context = _context
	add_child(_bridge)
	_context.bridge = _bridge

	_context.state_controller = BattleStateController.new()
	_context.state_controller.name = "BattleStateController"
	add_child(_context.state_controller)
	_context.state_controller.initialize(_context)

	_context.economy = BattleEconomy.new()
	_context.economy.name = "BattleEconomy"
	add_child(_context.economy)
	_context.economy.initialize(_context)

	_context.lives = LivesController.new()
	_context.lives.name = "LivesController"
	add_child(_context.lives)
	_context.lives.initialize(_context)

	_context.map_light = MapLightManager.new()
	_context.map_light.name = "MapLightManager"
	add_child(_context.map_light)
	_context.map_light.initialize(_context)

	_context.objectives = ObjectiveController.new()
	_context.objectives.name = "ObjectiveController"
	add_child(_context.objectives)
	_context.objectives.initialize(_context)

	_context.morale = MoraleController.new()
	_context.morale.name = "MoraleController"
	add_child(_context.morale)
	_context.morale.initialize(_context)

	_context.run_modifiers = RunModifierService.new()
	_context.run_modifiers.name = "RunModifierService"
	add_child(_context.run_modifiers)
	_context.run_modifiers.initialize(_context)

	_context.ancestral_forge = AncestralForgeController.new()
	_context.ancestral_forge.name = "AncestralForgeController"
	add_child(_context.ancestral_forge)
	_context.ancestral_forge.initialize(_context)

	if launch and launch.active_relic_ids.size() > 0:
		for rid in launch.active_relic_ids:
			var relic := ContentRegistry.get_relic(rid)
			if relic:
				_context.run_modifiers.add_relic(relic)

	_context.enemy_spawner = EnemySpawner.new()
	_context.enemy_spawner.name = "EnemySpawner"
	add_child(_context.enemy_spawner)
	_context.enemy_spawner.initialize(_context, _units_root)

	_context.wave_manager = WaveManager.new()
	_context.wave_manager.name = "WaveManager"
	add_child(_context.wave_manager)
	_context.wave_manager.initialize(_context)

	_context.tower_manager = TowerManager.new()
	_context.tower_manager.name = "TowerManager"
	add_child(_context.tower_manager)

	_context.hero_manager = HeroManager.new()
	_context.hero_manager.name = "HeroManager"
	add_child(_context.hero_manager)
	_context.hero_manager.initialize(_context, _heroes_root)

	_build_map_visuals(level)
	_assign_level_objective(level)
	var spots := _create_build_spots(level)
	_context.tower_manager.initialize(_context, spots, _towers_root, _projectiles_root)

	var fate_draft := FateDraftController.new()
	fate_draft.name = "FateDraftController"
	add_child(fate_draft)
	fate_draft.initialize(_context, _pardeh_panel)

	if _hud:
		_hud.initialize(_context, fate_draft)
	if level.is_tutorial:
		var tutorial := _tutorial_overlay_scene.instantiate() as TutorialController
		add_child(tutorial)
		tutorial.initialize(_context, _hud, self, fate_draft)
	if _camera:
		_camera.global_position = Vector2(640, 360)
		if level.uses_large_map_camera:
			_camera.configure_large_map(level.camera_anchors, level.gate_position)

	_connect_region_updates(spots)
	_apply_endless_or_hunt(launch, level)
	if _hud and _hud.has_method("setup_ancestral_forge"):
		_hud.setup_ancestral_forge(_context)
	if _hud and _hud.has_method("refresh_skill_label"):
		_hud.refresh_skill_label()

	if launch.auto_start:
		_context.state_controller.start_battle()


func _build_map_visuals(level: LevelData) -> void:
	if _path:
		var curve := Curve2D.new()
		for p in level.path_points:
			curve.add_point(p)
		_path.curve = curve
	if _gate:
		_gate.global_position = level.gate_position
	if _spawn_marker:
		_spawn_marker.global_position = level.spawn_position
	if _camera:
		_camera.global_position = Vector2(640, 360)
	var terrain := _map_root.get_node_or_null("Terrain") as ColorRect
	if terrain:
		terrain.color = VisualAssetLoader.map_terrain_color(level.level_id)
	_apply_map_background(level)


func _apply_map_background(level: LevelData) -> void:
	var existing := _map_root.get_node_or_null("MapBackground") as Sprite2D
	if existing:
		existing.queue_free()
	if level.map_sprite_path == "" or not ResourceLoader.exists(level.map_sprite_path):
		return
	var tex := load(level.map_sprite_path) as Texture2D
	if tex == null:
		return
	var spr := Sprite2D.new()
	spr.name = "MapBackground"
	spr.texture = tex
	spr.centered = false
	spr.position = Vector2.ZERO
	spr.z_index = -2
	var view_size := Vector2(1280, 720)
	var scale_factor := view_size / tex.get_size()
	spr.scale = Vector2(scale_factor.x, scale_factor.y)
	_map_root.add_child(spr)
	_map_root.move_child(spr, 0)


func _assign_level_objective(level: LevelData) -> void:
	if _context == null or _context.objectives == null or level.default_objective_id == "":
		return
	if not ContentRegistry:
		return
	var obj := ContentRegistry.get_objective(level.default_objective_id)
	if obj:
		_context.objectives.assign_objective(obj)


func _create_build_spots(level: LevelData) -> Array[BuildSpot]:
	var spots: Array[BuildSpot] = []
	var idx := 0
	var total := level.build_spot_positions.size()
	for pos in level.build_spot_positions:
		var spot := _build_spot_scene.instantiate() as BuildSpot
		spot.spot_id = "pad_%d" % idx
		spot.region_id = MapRegionUtils.region_for_pad_index(idx, total, level.region_ids)
		spot.global_position = pos
		_build_spots_root.add_child(spot)
		spots.append(spot)
		idx += 1
	return spots


func _connect_region_updates(spots: Array[BuildSpot]) -> void:
	if _bridge:
		_bridge.region_light_changed.connect(func(region_id: String, light: int, _state: GameEnums.RegionLightState) -> void:
			for spot in spots:
				if spot.region_id == region_id and spot.tower:
					spot.tower.on_region_light_changed(light)
		)


func _unhandled_input(event: InputEvent) -> void:
	if _context == null or _context.hero_manager == null:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var world := get_global_mouse_position()
		_context.hero_manager.handle_ground_tap(world)
	elif event is InputEventScreenTouch and event.pressed:
		var world := _screen_to_world(event.position)
		_context.hero_manager.handle_ground_tap(world)


func _apply_endless_or_hunt(launch: BattleLaunchData, level: LevelData) -> void:
	if launch == null or _context == null:
		return
	if launch.is_endless_mode and _context.wave_manager:
		_context.wave_manager.enable_endless_mode()
	if launch.is_hunt_mode:
		_context.runtime_modifiers["hunt_mode"] = true
		_context.hunt = HuntController.new()
		_context.hunt.name = "HuntController"
		add_child(_context.hunt)
		_context.hunt.initialize(_context)
		if _context.bridge:
			_context.bridge.alert_message.emit("Hunt for Zahhak — bind the darkness!", 80)
	elif level.level_id == "level_08_damavand" and not launch.is_hunt_mode:
		_context.runtime_modifiers["damavand_binding_progress"] = 0.0
		if _context.bridge:
			_context.bridge.enemy_died.connect(_on_damavand_enemy_died)


func _screen_to_world(screen_pos: Vector2) -> Vector2:
	var canvas := get_viewport().get_canvas_transform()
	return canvas.affine_inverse() * screen_pos


func _on_damavand_enemy_died(enemy_id: String) -> void:
	if _context == null:
		return
	var progress := float(_context.runtime_modifiers.get("damavand_binding_progress", 0.0))
	if enemy_id == "enemy_zahhak_serpent_guard":
		progress += 0.25
	elif enemy_id == "enemy_chainbreaker_div":
		progress += 0.35
	if progress >= 1.0 and _context.bridge:
		_context.bridge.alert_message.emit("Binding anchors shattered — Zahhak is vulnerable!", 90)
	_context.runtime_modifiers["damavand_binding_progress"] = progress


func _process(delta: float) -> void:
	if _context and _context.map_light:
		_context.map_light.tick_decay(delta)
		_context.map_light.process_hijack_timers(delta)
