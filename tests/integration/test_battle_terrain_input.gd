extends GutTest

const BATTLE_SCENE := preload("res://scenes/battle/battle.tscn")


func test_terrain_does_not_consume_clicks() -> void:
	var battle := BATTLE_SCENE.instantiate()
	add_child(battle)
	await get_tree().process_frame
	var terrain := battle.get_node_or_null("MapRoot/Terrain") as ColorRect
	assert_not_null(terrain, "Battle scene should include MapRoot/Terrain")
	assert_eq(
		terrain.mouse_filter,
		Control.MOUSE_FILTER_IGNORE,
		"Terrain must pass clicks through to battlefield tap handling"
	)
