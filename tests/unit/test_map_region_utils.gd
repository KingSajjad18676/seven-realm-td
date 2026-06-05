extends GutTest


func test_empty_regions_returns_empty_string() -> void:
	assert_eq(MapRegionUtils.region_for_position(Vector2.ZERO, [], []), "")
	assert_eq(MapRegionUtils.region_for_pad_index(0, 4, []), "")


func test_single_region_always_returns_it() -> void:
	var ids: Array[String] = ["north"]
	var path: Array[Vector2] = [Vector2(0, 0), Vector2(100, 0)]
	assert_eq(MapRegionUtils.region_for_position(Vector2(50, 50), path, ids), "north")
	assert_eq(MapRegionUtils.region_for_pad_index(3, 8, ids), "north")


func test_path_sector_mapping() -> void:
	var ids: Array[String] = ["a", "b", "c"]
	var path: Array[Vector2] = [
		Vector2(0, 0),
		Vector2(50, 0),
		Vector2(100, 0),
		Vector2(150, 0),
	]
	assert_eq(MapRegionUtils.region_for_position(Vector2(0, 0), path, ids), "a")
	assert_eq(MapRegionUtils.region_for_position(Vector2(150, 0), path, ids), "c")


func test_pad_index_clamps_to_region_count() -> void:
	var ids: Array[String] = ["r0", "r1", "r2"]
	assert_eq(MapRegionUtils.region_for_pad_index(0, 6, ids), "r0")
	assert_eq(MapRegionUtils.region_for_pad_index(5, 6, ids), "r2")
