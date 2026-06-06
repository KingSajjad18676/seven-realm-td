class_name RelicSlotHelper
extends RefCounted


static func pick_relic_pool(
	tower_ids: Array[String],
	slots: Dictionary,
	count: int = 3
) -> Array[RelicData]:
	var pool := _pool_for_towers(tower_ids, slots)
	if pool.is_empty() and ContentRegistry:
		for relic in ContentRegistry.get_all_relics():
			if relic.is_global_relic():
				pool.append(relic)
	pool.shuffle()
	var picks: Array[RelicData] = []
	for i in range(mini(count, pool.size())):
		picks.append(pool[i])
	return picks


static func _pool_for_towers(tower_ids: Array[String], slots: Dictionary) -> Array[RelicData]:
	if ContentRegistry == null:
		return []
	var unslotted: Array[RelicData] = []
	var slotted: Array[RelicData] = []
	for relic in ContentRegistry.get_relics_for_towers(tower_ids):
		if relic.slot_tower_id in slots:
			slotted.append(relic)
		else:
			unslotted.append(relic)
	if not unslotted.is_empty():
		return unslotted
	return slotted


static func apply_slot(slots: Dictionary, tower_id: String, relic_id: String) -> Dictionary:
	var copy := slots.duplicate()
	copy[tower_id] = relic_id
	return copy


static func migrate_relic_ids(relic_ids: Array) -> Dictionary:
	var slots: Dictionary = {}
	var globals: Array[String] = []
	for raw_id in relic_ids:
		var relic_id := str(raw_id)
		if relic_id == "":
			continue
		var relic := ContentRegistry.get_relic(relic_id) if ContentRegistry else null
		if relic == null:
			continue
		if relic.is_tower_relic():
			if not slots.has(relic.slot_tower_id):
				slots[relic.slot_tower_id] = relic_id
		else:
			globals.append(relic_id)
	return {"tower_relic_slots": slots, "active_relic_ids": globals}


static func format_loadout_line(tower_ids: Array[String], slots: Dictionary) -> String:
	var parts: PackedStringArray = PackedStringArray()
	for tower_id in tower_ids:
		var td := ContentRegistry.get_tower(tower_id) if ContentRegistry else null
		var name := td.display_name if td else tower_id
		var relic_id := str(slots.get(tower_id, ""))
		if relic_id != "":
			var relic := ContentRegistry.get_relic(relic_id) if ContentRegistry else null
			if relic:
				parts.append("%s (%s)" % [name, relic.title])
				continue
		parts.append("%s" % name)
	return ", ".join(parts)
