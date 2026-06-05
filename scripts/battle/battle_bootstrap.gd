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
var _contextual_hint_scene: PackedScene = preload("res://scenes/ui/contextual_hint_overlay.tscn")
var _touch_pending: bool = false
var _touch_start_screen: Vector2 = Vector2.ZERO
var _touch_start_world: Vector2 = Vector2.ZERO


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
	level.ensure_routes_migrated()
	level.ensure_spawns_migrated()
	_context.path_points = level.get_route()

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

	_context.loot_drops = LootDropManager.new()
	_context.loot_drops.name = "LootDropManager"
	add_child(_context.loot_drops)
	_context.loot_drops.initialize(_context, _units_root)

	_context.wave_manager = WaveManager.new()
	_context.wave_manager.name = "WaveManager"
	add_child(_context.wave_manager)
	_context.wave_manager.initialize(_context)

	_context.spell_controller = SpellController.new()
	_context.spell_controller.name = "SpellController"
	add_child(_context.spell_controller)
	_context.spell_controller.initialize(_context)

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
	_context.tower_manager.initialize(_context, spots, _towers_root, _projectiles_root, _units_root)

	var fate_draft := FateDraftController.new()
	fate_draft.name = "FateDraftController"
	add_child(fate_draft)
	fate_draft.initialize(_context, _pardeh_panel)

	var vow_offer := VowOfferController.new()
	vow_offer.name = "VowOfferController"
	add_child(vow_offer)
	vow_offer.initialize(_context, _pardeh_panel)

	if _hud:
		_hud.initialize(_context, fate_draft, vow_offer)
		var range_ring := TowerRangeRing.new()
		range_ring.name = "TowerRangeRing"
		range_ring.z_index = 2
		_map_root.add_child(range_ring)
		if _hud.has_method("setup_tower_range_ring"):
			_hud.setup_tower_range_ring(range_ring)
		if _hud.has_method("setup_camera_ui"):
			_hud.setup_camera_ui(_camera)
	if level.is_tutorial:
		var tutorial := _tutorial_overlay_scene.instantiate() as TutorialController
		if tutorial == null:
			push_error("BattleBootstrap: failed to instantiate TutorialController")
		else:
			add_child(tutorial)
			tutorial.call_deferred("initialize", _context, _hud, self, fate_draft)
	else:
		var hints := _contextual_hint_scene.instantiate() as ContextualHintController
		if hints == null:
			push_error("BattleBootstrap: failed to instantiate ContextualHintController")
		else:
			add_child(hints)
			hints.call_deferred("initialize", _context, _hud)
	if _camera:
		_camera.configure_from_level(level)

	_connect_region_updates(spots)
	_apply_difficulty_and_unlocks(launch, level)
	_apply_campaign_run(launch, level)
	_apply_endless_or_hunt(launch, level)
	_attach_labour_mode(launch, level)
	if _hud and _hud.has_method("setup_ancestral_forge"):
		_hud.setup_ancestral_forge(_context)
	if _hud and _hud.has_method("refresh_skill_label"):
		_hud.refresh_skill_label()

	if launch.auto_start:
		_context.state_controller.start_battle()


func _build_map_visuals(level: LevelData) -> void:
	level.ensure_routes_migrated()
	level.ensure_spawns_migrated()
	var has_map_art := _level_has_map_art(level)
	_clear_dev_map_overlays()
	if _path:
		var primary := level.get_route()
		var curve := Curve2D.new()
		for p in primary:
			curve.add_point(p)
		_path.curve = curve
		_apply_path_line(primary, has_map_art)
		_apply_extra_route_lines(level, has_map_art)
	if _gate:
		_gate.global_position = level.gate_position
	if _spawn_marker:
		_spawn_marker.global_position = level.get_spawn().get("position", level.spawn_position)
	_apply_spawn_markers(level, has_map_art)
	_set_dev_map_markers_visible(not has_map_art)
	var terrain := _map_root.get_node_or_null("Terrain") as ColorRect
	if terrain:
		terrain.color = VisualAssetLoader.map_terrain_color(level.level_id)
		terrain.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_apply_map_background(level)


func _clear_dev_map_overlays() -> void:
	for node_name in ["DevRoutes", "DevSpawns"]:
		var existing := _map_root.get_node_or_null(node_name)
		if existing:
			existing.queue_free()


func _apply_extra_route_lines(level: LevelData, has_map_art: bool) -> void:
	if level.path_routes.size() <= 1:
		return
	var container := Node2D.new()
	container.name = "DevRoutes"
	_map_root.add_child(container)
	for i in level.path_routes.size():
		var route := level.path_routes[i]
		var line := Line2D.new()
		line.points = PackedVector2Array(route.points)
		line.width = 6.0
		line.default_color = MapEditorUtils.route_color(i)
		line.z_index = -1
		line.visible = not has_map_art
		container.add_child(line)


func _apply_spawn_markers(level: LevelData, has_map_art: bool) -> void:
	if level.spawn_points.is_empty():
		return
	var container := Node2D.new()
	container.name = "DevSpawns"
	_map_root.add_child(container)
	for spawn in level.spawn_points:
		var marker := Node2D.new()
		marker.global_position = spawn.position
		var visual := ColorRect.new()
		visual.offset_left = -20.0
		visual.offset_top = -40.0
		visual.offset_right = 20.0
		visual.offset_bottom = 40.0
		visual.color = Color(0.9, 0.25, 0.2, 0.95)
		visual.visible = not has_map_art
		marker.add_child(visual)
		container.add_child(marker)


func _level_has_map_art(level: LevelData) -> bool:
	return level.map_sprite_path != "" and ResourceLoader.exists(level.map_sprite_path)


func _set_dev_map_markers_visible(visible: bool) -> void:
	var gate_visual := _gate.get_node_or_null("GateVisual") if _gate else null
	if gate_visual:
		gate_visual.visible = visible
	for child in _spawn_marker.get_children() if _spawn_marker else []:
		child.visible = visible
	var dev_routes := _map_root.get_node_or_null("DevRoutes")
	if dev_routes:
		dev_routes.visible = visible
	var dev_spawns := _map_root.get_node_or_null("DevSpawns")
	if dev_spawns:
		for child in dev_spawns.get_children():
			for visual in child.get_children():
				visual.visible = visible


func _apply_path_line(points: Array[Vector2], has_map_art: bool = false) -> void:
	if _path == null or points.is_empty():
		return
	var line := _path.get_node_or_null("PathLine") as Line2D
	if line == null:
		line = Line2D.new()
		line.name = "PathLine"
		_path.add_child(line)
	line.z_index = -1
	if has_map_art:
		line.visible = false
	else:
		line.visible = true
		line.width = 6.0
		line.default_color = Color(0.72, 0.58, 0.38, 0.35)
		line.points = PackedVector2Array(points)


func _apply_map_background(level: LevelData) -> void:
	var terrain := _map_root.get_node_or_null("Terrain") as ColorRect
	var existing := _map_root.get_node_or_null("MapBackground") as Sprite2D
	if existing:
		existing.queue_free()
	if level.map_sprite_path == "" or not ResourceLoader.exists(level.map_sprite_path):
		if terrain:
			terrain.visible = true
		return
	var tex := load(level.map_sprite_path) as Texture2D
	if tex == null:
		if terrain:
			terrain.visible = true
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
	if terrain:
		terrain.visible = false


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
	_handle_battlefield_tap(event)


func _handle_battlefield_tap(event: InputEvent) -> void:
	if _context == null or _context.hero_manager == null:
		return
	if _hud and _hud.has_method("is_tower_radial_open") and _hud.is_tower_radial_open():
		return
	if _context.tutorial_active and not _context.tutorial_allows("battlefield") \
			and not _context.tutorial_allows("build_pads"):
		return
	if event is InputEventScreenTouch:
		_handle_screen_touch_tap(event as InputEventScreenTouch)
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _camera and _camera.should_block_battlefield_tap():
			return
		_apply_battlefield_tap(_screen_to_world(event.position))
		get_viewport().set_input_as_handled()


func _handle_screen_touch_tap(event: InputEventScreenTouch) -> void:
	if event.pressed:
		_touch_pending = true
		_touch_start_screen = event.position
		_touch_start_world = _screen_to_world(event.position)
		return
	if not _touch_pending:
		return
	_touch_pending = false
	if _camera and _camera.should_block_battlefield_tap():
		return
	if event.position.distance_to(_touch_start_screen) >= TouchCamera.DRAG_THRESHOLD:
		return
	_apply_battlefield_tap(_touch_start_world)
	get_viewport().set_input_as_handled()


func _apply_battlefield_tap(world: Vector2) -> void:
	if _context.tower_manager and _context.tower_manager.try_select_spot_at_world(world):
		return
	if _context.tutorial_active and not _context.tutorial_allows("battlefield"):
		return
	_context.hero_manager.handle_ground_tap(world)


func _apply_campaign_run(launch: BattleLaunchData, level: LevelData) -> void:
	if _context == null or level == null or launch == null:
		return
	if launch.run_tower_ids.size() >= 3:
		level.available_tower_ids = launch.run_tower_ids.duplicate()
	for tower_id in launch.run_tower_upgrades.keys():
		var bonus := int(launch.run_tower_upgrades.get(tower_id, 0))
		if bonus > 0:
			_context.runtime_modifiers["run_upgrade_%s" % tower_id] = bonus
	if launch.is_campaign_run and launch.skirmish_waves > 0 and _context.wave_manager:
		_context.wave_manager.enable_skirmish_mode(launch.skirmish_waves)
		if _context.bridge:
			_context.bridge.alert_message.emit(
				"Campaign Run — survive %d waves and scavenge Star Iron!" % launch.skirmish_waves,
				90
			)
	elif launch.is_campaign_run and launch.skirmish_waves == 0:
		if _context.bridge:
			_context.bridge.alert_message.emit("Campaign Run — bank materials or retreat at Pardeh.", 80)


func _apply_difficulty_and_unlocks(launch: BattleLaunchData, level: LevelData) -> void:
	if _context == null or level == null:
		return
	if launch and launch.run_tower_ids.size() >= 3:
		return
	var diff := ContentCatalog.khan_difficulty(level.level_id)
	var hp_mult := float(diff.hp_mult)
	var speed_mult := float(diff.speed_mult)
	if launch and launch.is_horde_mode:
		hp_mult *= 1.15
		speed_mult *= 1.08
	_context.runtime_modifiers["enemy_hp_mult"] = hp_mult
	_context.runtime_modifiers["enemy_speed_mult"] = speed_mult
	if SaveSystem and SaveSystem.is_tower_unlocked("tower_zahhak_serpent"):
		if "tower_zahhak_serpent" not in level.available_tower_ids:
			level.available_tower_ids.append("tower_zahhak_serpent")
	if SaveSystem and SaveSystem.is_tower_unlocked("tower_rostam_barracks"):
		if "tower_rostam_barracks" not in level.available_tower_ids:
			level.available_tower_ids.append("tower_rostam_barracks")


func _apply_endless_or_hunt(launch: BattleLaunchData, level: LevelData) -> void:
	if launch == null or _context == null:
		return
	if launch.is_endless_mode and _context.wave_manager:
		_context.wave_manager.enable_endless_mode()
	if launch.is_horde_mode and _context.wave_manager:
		_context.wave_manager.enable_horde_mode()
		if _context.bridge:
			_context.bridge.alert_message.emit(
				"Horde Mode — survive %d waves!" % ContentCatalog.HORDE_WAVES_TO_CLEAR,
				90
			)
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


func _attach_labour_mode(launch: BattleLaunchData, level: LevelData) -> void:
	if launch == null or _context == null or level == null:
		return
	if not launch.is_campaign_mode():
		return
	if level.labour_mode_id == "":
		level.labour_mode_id = LabourModeFactory.labour_mode_id_for_level(level.level_id)
	var mode := LabourModeFactory.create(level)
	if mode == null:
		return
	mode.name = "LabourMode_%s" % level.labour_mode_id
	add_child(mode)
	mode.initialize(_context)
	_context.labour_mode = mode
	if not CombatEvents.wave_started.is_connected(_on_labour_wave_started):
		CombatEvents.wave_started.connect(_on_labour_wave_started)
	if not CombatEvents.wave_completed.is_connected(_on_labour_wave_completed):
		CombatEvents.wave_completed.connect(_on_labour_wave_completed)
	if not CombatEvents.cleanse_used.is_connected(_on_labour_cleanse):
		CombatEvents.cleanse_used.connect(_on_labour_cleanse)


func _on_labour_wave_started(wave_index: int) -> void:
	if _context and _context.labour_mode:
		_context.labour_mode.on_wave_started(wave_index)


func _on_labour_wave_completed(wave_index: int) -> void:
	if _context and _context.labour_mode:
		_context.labour_mode.on_wave_completed(wave_index)


func _on_labour_cleanse(region_id: String) -> void:
	if _context and _context.labour_mode:
		_context.labour_mode.on_cleanse(region_id)


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
	if _context and _context.spell_controller:
		_context.spell_controller.tick(delta)
