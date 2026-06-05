class_name MapRegionUtils
extends RefCounted


static func region_for_position(pos: Vector2, path: Array[Vector2], region_ids: Array[String]) -> String:
	if region_ids.is_empty():
		return ""
	if region_ids.size() == 1:
		return region_ids[0]
	if path.is_empty():
		return region_ids[0]
	var best_idx := 0
	var best_dist := INF
	for i in path.size():
		var d := pos.distance_squared_to(path[i])
		if d < best_dist:
			best_dist = d
			best_idx = i
	var t := float(best_idx) / float(maxi(1, path.size() - 1))
	var sector := int(t * float(region_ids.size()))
	sector = clampi(sector, 0, region_ids.size() - 1)
	return region_ids[sector]


static func region_for_pad_index(index: int, total: int, region_ids: Array[String]) -> String:
	if region_ids.is_empty():
		return ""
	if region_ids.size() == 1:
		return region_ids[0]
	var sector := int(float(index) / float(maxi(1, total)) * float(region_ids.size()))
	sector = clampi(sector, 0, region_ids.size() - 1)
	return region_ids[sector]
