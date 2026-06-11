extends Control

@onready var _level_select: OptionButton = %LevelSelect
@onready var _tool_road: Button = %ToolRoad
@onready var _tool_pads: Button = %ToolPads
@onready var _tool_spawn: Button = %ToolSpawn
@onready var _tool_gate: Button = %ToolGate
@onready var _tool_select: Button = %ToolSelect
@onready var _route_select: OptionButton = %RouteSelect
@onready var _spawn_route_select: OptionButton = %SpawnRouteSelect
@onready var _spawn_route_label: Label = %SpawnRouteLabel
@onready var _snap_toggle: CheckBox = %SnapToggle
@onready var _region_input: LineEdit = %RegionInput
@onready var _coord_label: Label = %CoordLabel
@onready var _status_label: Label = %StatusLabel
@onready var _canvas: MapEditorCanvas = %MapCanvas
@onready var _camera: MapEditorCamera = %EditorCamera
@onready var _pad_count_spin: SpinBox = %PadCountSpin
@onready var _zoom_label: Label = %ZoomLabel

var _levels: Array[LevelData] = []
var _current_level_id: String = ""
var _dirty: bool = false


func _ready() -> void:
	_populate_levels()
	_wire_toolbar()
	if _canvas:
		_canvas.geometry_changed.connect(_on_geometry_changed)
		_canvas.cursor_moved.connect(_on_cursor_moved)
		_canvas.routes_changed.connect(_refresh_route_selectors)
	if _camera:
		_camera.zoom_changed.connect(_on_zoom_changed)
		_on_zoom_changed(_camera.zoom.x)
	if _level_select and _level_select.item_count > 0:
		_level_select.select(0)
		_load_selected_level()
	if _spawn_route_select:
		_spawn_route_select.visible = false
	if _spawn_route_label:
		_spawn_route_label.visible = false
	if OS.is_debug_build():
		print("Map Editor: F6 scene — edit geometry, Save writes resources/data/levels/{id}.tres")


func _populate_levels() -> void:
	_levels.clear()
	_level_select.clear()
	if ContentRegistry and ContentRegistry.bootstrap:
		for level in ContentRegistry.bootstrap.levels:
			_levels.append(level)
			_level_select.add_item("%s — %s" % [level.level_id, level.display_name], _levels.size() - 1)


func _wire_toolbar() -> void:
	_level_select.item_selected.connect(_on_level_selected)
	_tool_road.pressed.connect(func() -> void: _set_tool(MapEditorCanvas.Tool.ROAD))
	if _tool_pads:
		_tool_pads.visible = false
	_tool_spawn.pressed.connect(func() -> void: _set_tool(MapEditorCanvas.Tool.SPAWN))
	_tool_gate.pressed.connect(func() -> void: _set_tool(MapEditorCanvas.Tool.GATE))
	_tool_select.pressed.connect(func() -> void: _set_tool(MapEditorCanvas.Tool.SELECT))
	_route_select.item_selected.connect(_on_route_selected)
	_spawn_route_select.item_selected.connect(_on_spawn_route_selected)
	_snap_toggle.toggled.connect(_on_snap_toggled)
	_region_input.text_submitted.connect(_on_regions_submitted)
	_region_input.focus_exited.connect(func() -> void: _on_regions_submitted(_region_input.text))
	%SaveButton.pressed.connect(_on_save_pressed)
	%ReloadButton.pressed.connect(_load_selected_level)
	%ClearToolButton.pressed.connect(_on_clear_tool_pressed)
	if has_node("%AutoPadsButton"):
		get_node("%AutoPadsButton").visible = false
	if _pad_count_spin:
		_pad_count_spin.visible = false
	%FitMapButton.pressed.connect(_on_fit_map_pressed)
	%BackButton.pressed.connect(_on_back_pressed)
	%AddRouteButton.pressed.connect(_on_add_route_pressed)
	%DeleteRouteButton.pressed.connect(_on_delete_route_pressed)
	_snap_toggle.button_pressed = true


func _load_selected_level() -> void:
	if _level_select.selected < 0 or _level_select.selected >= _levels.size():
		return
	var level_id := _levels[_level_select.selected].level_id
	var level := ContentRegistry.get_level(level_id) if ContentRegistry else _levels[_level_select.selected]
	if level == null:
		return
	_current_level_id = level.level_id
	var state := MapEditorUtils.apply_level_to_state(level)
	_canvas.load_geometry(state)
	_region_input.text = ", ".join(level.region_ids)
	_refresh_route_selectors()
	_dirty = false
	_update_tool_status()
	if _camera:
		_camera.fit_to_map()


func _on_level_selected(_index: int) -> void:
	if _dirty:
		_set_status("Unsaved changes discarded when switching levels.")
	_load_selected_level()


func _set_tool(tool: MapEditorCanvas.Tool) -> void:
	_canvas.active_tool = tool
	var show_spawn_route := tool == MapEditorCanvas.Tool.SPAWN
	if _spawn_route_select:
		_spawn_route_select.visible = show_spawn_route
	if _spawn_route_label:
		_spawn_route_label.visible = show_spawn_route
	_update_tool_status()


func _update_tool_status() -> void:
	if _canvas == null:
		return
	var tool_names := {
		MapEditorCanvas.Tool.ROAD: "Road",
		MapEditorCanvas.Tool.SPAWN: "Spawn",
		MapEditorCanvas.Tool.GATE: "Gate",
		MapEditorCanvas.Tool.SELECT: "Select",
	}
	var route_id := _canvas.get_active_route_id()
	var spawn_count := _canvas.spawn_points.size()
	_set_status(
		"Tool: %s — route %s, %d spawn(s). LMB place/drag, RMB delete (road/spawn)."
		% [tool_names.get(_canvas.active_tool, "Road"), route_id, spawn_count]
	)


func _refresh_route_selectors() -> void:
	if _canvas == null:
		return
	var keep_route := _canvas.get_active_route_id()
	var keep_spawn_route := _canvas.spawn_route_id
	_route_select.clear()
	_spawn_route_select.clear()
	for i in _canvas.path_routes.size():
		var route_id: String = str(_canvas.path_routes[i].get("route_id", "route_%d" % (i + 1)))
		_route_select.add_item(route_id, i)
		_spawn_route_select.add_item(route_id, i)
	var route_index := 0
	for i in _canvas.path_routes.size():
		if str(_canvas.path_routes[i].get("route_id", "")) == keep_route:
			route_index = i
			break
	_route_select.select(route_index)
	_canvas.set_active_route_index(route_index)
	var spawn_route_index := route_index
	for i in _canvas.path_routes.size():
		if str(_canvas.path_routes[i].get("route_id", "")) == keep_spawn_route:
			spawn_route_index = i
			break
	_spawn_route_select.select(spawn_route_index)
	_canvas.spawn_route_id = str(_canvas.path_routes[spawn_route_index].get("route_id", LevelData.PRIMARY_ROUTE_ID))


func _on_route_selected(index: int) -> void:
	if _canvas:
		_canvas.set_active_route_index(index)
		_update_tool_status()


func _on_spawn_route_selected(index: int) -> void:
	if _canvas and index >= 0 and index < _canvas.path_routes.size():
		_canvas.spawn_route_id = str(_canvas.path_routes[index].get("route_id", LevelData.PRIMARY_ROUTE_ID))


func _on_add_route_pressed() -> void:
	if _canvas:
		_canvas.add_route()
		_refresh_route_selectors()
		_update_tool_status()


func _on_delete_route_pressed() -> void:
	if _canvas and _canvas.delete_active_route():
		_refresh_route_selectors()
		_update_tool_status()
	else:
		_set_status("Cannot delete the last route.")


func _on_snap_toggled(enabled: bool) -> void:
	_canvas.snap_enabled = enabled


func _on_regions_submitted(text: String) -> void:
	var ids: Array[String] = []
	for part in text.split(","):
		var id := part.strip_edges()
		if id != "":
			ids.append(id)
	_canvas.region_ids = ids
	_canvas.queue_redraw()
	_on_geometry_changed()


func _on_geometry_changed() -> void:
	_dirty = true
	_update_tool_status()


func _on_cursor_moved(world_pos: Vector2) -> void:
	_coord_label.text = "Cursor: (%d, %d)" % [int(world_pos.x), int(world_pos.y)]


func _on_clear_tool_pressed() -> void:
	_canvas.clear_active_tool_data()
	_set_status("Cleared active tool data.")


func _on_auto_pads_pressed() -> void:
	var count := int(_pad_count_spin.value)
	_canvas.auto_pads_along_path(count)
	_set_status("Generated %d pads along active route." % count)


func _on_save_pressed() -> void:
	if _current_level_id == "":
		_set_status("No level selected.")
		return
	var existing := MapEditorUtils.load_existing_override(_current_level_id)
	var geometry := _canvas.get_geometry_state()
	geometry["uses_large_map_camera"] = existing.uses_large_map_camera if existing else false
	geometry["camera_anchors"] = existing.camera_anchors.duplicate() if existing else []
	geometry["grid_width"] = existing.grid_width if existing else 32
	geometry["grid_height"] = existing.grid_height if existing else 18
	var payload := MapEditorUtils.merge_save_payload(_current_level_id, geometry, existing)
	var save_path := MapEditorUtils.override_path(_current_level_id)
	var err := ResourceSaver.save(payload, save_path)
	if err != OK:
		_set_status("Save failed (error %d): %s" % [err, save_path])
		return
	if ContentRegistry:
		ContentRegistry.reload()
		var keep_id := _current_level_id
		_populate_levels()
		for i in _levels.size():
			if _levels[i].level_id == keep_id:
				_level_select.select(i)
				break
	_dirty = false
	_set_status("Saved %s" % save_path)


func _on_fit_map_pressed() -> void:
	if _camera:
		_camera.fit_to_map()


func _on_zoom_changed(zoom_level: float) -> void:
	if _zoom_label:
		_zoom_label.text = "Zoom: %d%%" % int(roundf(zoom_level * 100.0))


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")


func _set_status(message: String) -> void:
	if _status_label:
		_status_label.text = message


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_0:
				_on_fit_map_pressed()
			KEY_1:
				_set_tool(MapEditorCanvas.Tool.ROAD)
			KEY_2:
				_set_tool(MapEditorCanvas.Tool.SPAWN)
			KEY_3:
				_set_tool(MapEditorCanvas.Tool.GATE)
			KEY_4:
				_set_tool(MapEditorCanvas.Tool.SELECT)
	elif event is InputEventKey and event.keycode == KEY_SPACE and _canvas:
		_canvas.input_blocked = event.pressed
