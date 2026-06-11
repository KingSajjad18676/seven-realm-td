extends GutTest

const BATTLE_SCENE := preload("res://scenes/battle/battle.tscn")


func test_level_01_hides_terrain_when_map_art_loads() -> void:
	var launch := BattleLaunchData.new()
	launch.level_id = "level_01"
	launch.auto_start = false
	SceneFlowController.pending_launch = launch
	var battle := BATTLE_SCENE.instantiate()
	add_child(battle)
	await get_tree().process_frame
	var terrain := battle.get_node_or_null("MapRoot/Terrain") as ColorRect
	var background := battle.get_node_or_null("MapRoot/MapBackground") as Sprite2D
	assert_not_null(terrain)
	assert_not_null(background, "level_01 should spawn MapBackground from map_sprite_path override")
	assert_false(terrain.visible, "Terrain fallback must hide when map art loads")


func test_level_without_map_art_keeps_terrain_visible() -> void:
	var launch := BattleLaunchData.new()
	launch.level_id = "level_02"
	launch.auto_start = false
	SceneFlowController.pending_launch = launch
	var battle := BATTLE_SCENE.instantiate()
	add_child(battle)
	await get_tree().process_frame
	var terrain := battle.get_node_or_null("MapRoot/Terrain") as ColorRect
	var background := battle.get_node_or_null("MapRoot/MapBackground")
	assert_not_null(terrain)
	assert_true(terrain.visible, "Terrain fallback stays visible when no map art")
	assert_null(background)


func test_level_01_camera_is_fit_locked() -> void:
	var launch := BattleLaunchData.new()
	launch.level_id = "level_01"
	launch.auto_start = false
	SceneFlowController.pending_launch = launch
	var battle := BATTLE_SCENE.instantiate()
	add_child(battle)
	await get_tree().process_frame
	var camera := battle.get_node_or_null("Camera2D") as TouchCamera
	assert_not_null(camera)
	assert_true(camera.is_camera_locked())
	assert_almost_eq(camera.global_position.x, 640.0, 1.0)
	assert_almost_eq(camera.global_position.y, 360.0, 1.0)
	assert_almost_eq(camera.zoom.x, 1.0, 0.01)
	var minimap := battle.get_node_or_null("CanvasLayer/TopRightStack/MinimapPanel") as MinimapController
	assert_not_null(minimap)
	assert_true(minimap.visible, "Khan 1 should show static route minimap top-right")
	assert_eq(minimap.mouse_filter, Control.MOUSE_FILTER_IGNORE, "Locked camera minimap is read-only")
	var tower_buttons := battle.get_node_or_null("CanvasLayer/BottomBar/TowerButtons")
	assert_null(tower_buttons, "Bottom tower bar removed; build via radial on pad tap")
