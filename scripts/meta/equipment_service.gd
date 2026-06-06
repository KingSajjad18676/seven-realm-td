extends Node

## Meta equipment loadout — owned pieces, equip slots, boss drops, daily chest.


const DUPLICATE_FORGE_TOKENS := 25
const CHEST_FALLBACK_TOKENS := 25


func get_owned_piece_ids() -> Array[String]:
	if not SaveSystem:
		return []
	var raw: Variant = SaveSystem.get_save_data().get("equipment_owned", [])
	var out: Array[String] = []
	if raw is Array:
		for entry in raw:
			if entry is String:
				out.append(entry)
	return out


func is_owned(piece_id: String) -> bool:
	return piece_id in get_owned_piece_ids()


func grant_piece(piece_id: String) -> bool:
	if piece_id == "" or not SaveSystem:
		return false
	if is_owned(piece_id):
		return false
	var owned := get_owned_piece_ids()
	owned.append(piece_id)
	SaveSystem.set_equipment_owned(owned)
	return true


func grant_duplicate_compensation() -> void:
	if SaveSystem:
		SaveSystem.add_forge_tokens(DUPLICATE_FORGE_TOKENS)


func grant_boss_drops(level_id: String) -> Array[String]:
	var granted: Array[String] = []
	if not ContentRegistry:
		return granted
	for piece in ContentRegistry.get_equipment_for_level(level_id):
		if is_owned(piece.piece_id):
			grant_duplicate_compensation()
			continue
		if grant_piece(piece.piece_id):
			granted.append(piece.piece_id)
	return granted


func open_daily_loot_chest() -> Dictionary:
	var pool: Array[EquipmentPieceData] = []
	if ContentRegistry:
		for piece in ContentRegistry.get_daily_equipment_pool():
			if not is_owned(piece.piece_id):
				pool.append(piece)
	if pool.is_empty():
		if SaveSystem:
			SaveSystem.add_forge_tokens(CHEST_FALLBACK_TOKENS)
		return {"type": "tokens", "amount": CHEST_FALLBACK_TOKENS}
	var pick := pool[randi() % pool.size()]
	grant_piece(pick.piece_id)
	return {"type": "equipment", "piece_id": pick.piece_id}


func get_equipped_map() -> Dictionary:
	if not SaveSystem:
		return {"weapon": "", "armor": "", "helm": "", "talisman": ""}
	return SaveSystem.get_equipment_equipped()


func get_equipped_piece_ids() -> Array[String]:
	var ids: Array[String] = []
	for slot in ["weapon", "armor", "helm", "talisman"]:
		var pid := str(get_equipped_map().get(slot, ""))
		if pid != "":
			ids.append(pid)
	return ids


func get_equipped_pieces() -> Array[EquipmentPieceData]:
	var out: Array[EquipmentPieceData] = []
	if not ContentRegistry:
		return out
	for pid in get_equipped_piece_ids():
		var piece := ContentRegistry.get_equipment_piece(pid)
		if piece:
			out.append(piece)
	return out


func count_equipped_for_set(set_id: String) -> int:
	var count := 0
	for piece in get_equipped_pieces():
		if piece.set_id == set_id:
			count += 1
	return count


func equip_piece(piece_id: String) -> bool:
	if piece_id == "" or not is_owned(piece_id) or not ContentRegistry or not SaveSystem:
		return false
	var piece := ContentRegistry.get_equipment_piece(piece_id)
	if piece == null:
		return false
	var equipped := get_equipped_map().duplicate()
	var slot_key := EquipmentPieceData.slot_key(piece.slot_type)
	equipped[slot_key] = piece_id
	SaveSystem.set_equipment_equipped(equipped)
	return true


func unequip_slot(slot_key: String) -> void:
	if not SaveSystem:
		return
	var equipped := get_equipped_map().duplicate()
	if equipped.has(slot_key):
		equipped[slot_key] = ""
		SaveSystem.set_equipment_equipped(equipped)


func apply_to_launch(launch: BattleLaunchData) -> void:
	if launch == null:
		return
	launch.equipped_piece_ids = get_equipped_piece_ids()


func get_set_bonus_tiers() -> Dictionary:
	var tiers: Dictionary = {}
	for piece in get_equipped_pieces():
		var sid := piece.set_id
		tiers[sid] = int(tiers.get(sid, 0)) + 1
	return tiers
