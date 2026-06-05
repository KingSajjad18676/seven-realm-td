extends GutTest


func test_preload_known_texture_reaches_full_progress() -> void:
	var path := VisualAssetLoader.khan1_sprite("enemy_jackal")
	assert_ne(path, "", "fixture texture should exist")
	var last_progress := 0.0
	var progress_cb := func(ratio: float) -> void:
		last_progress = ratio
	await LevelAssetPreloader.preload_paths(PackedStringArray([path]), progress_cb)
	assert_eq(last_progress, 1.0)
	assert_true(ResourceLoader.has_cached(path))


func test_preload_skips_missing_paths() -> void:
	var last_progress := 0.0
	var progress_cb := func(ratio: float) -> void:
		last_progress = ratio
	await LevelAssetPreloader.preload_paths(
		PackedStringArray(["res://art/_missing_texture.png"]),
		progress_cb
	)
	assert_eq(last_progress, 1.0)
