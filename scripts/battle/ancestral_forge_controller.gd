class_name AncestralForgeController
extends Node

## Adjacent-tower hybrid prototype (distinct from Kaveh's meta forge).

const RECIPES: Dictionary = {
	"tower_sacred_fire+tower_archer": "tower_flame_archer",
	"tower_heavy+tower_sacred_fire": "tower_volcano_ram",
}

var context: BattleContext = null


func initialize(ctx: BattleContext) -> void:
	context = ctx


func try_fuse_any_adjacent_pair() -> bool:
	if context == null or context.tower_manager == null:
		return false
	var spots := context.tower_manager.build_spots
	for i in spots.size():
		for j in range(i + 1, spots.size()):
			var a: BuildSpot = spots[i]
			var b: BuildSpot = spots[j]
			if a.tower == null or b.tower == null:
				continue
			if a.global_position.distance_to(b.global_position) > 160.0:
				continue
			if try_fuse_adjacent(a, b):
				return true
	return false


func try_fuse_adjacent(spot_a: BuildSpot, spot_b: BuildSpot) -> bool:
	if context == null or spot_a == null or spot_b == null:
		return false
	if spot_a.tower == null or spot_b.tower == null:
		return false
	var key := "%s+%s" % [spot_a.tower.data.tower_id, spot_b.tower.data.tower_id]
	var alt := "%s+%s" % [spot_b.tower.data.tower_id, spot_a.tower.data.tower_id]
	var hybrid_id: String = RECIPES.get(key, RECIPES.get(alt, ""))
	if hybrid_id == "":
		return false
	if context.bridge:
		context.bridge.alert_message.emit("Ancestral Forge: %s forged!" % hybrid_id, 65)
	context.runtime_modifiers["hybrid_%s" % hybrid_id] = 1.15
	return true
