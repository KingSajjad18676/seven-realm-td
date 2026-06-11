extends Node

const TINT_OVERRIDES: Dictionary = {
	"skin_rostam_nowruz": {"rostam": Color(0.85, 0.35, 0.45)},
	"skin_gate_damavand": {"gate": Color(0.45, 0.55, 0.85)},
	"hud_manuscript_theme": {"hud": Color(0.72, 0.58, 0.38)},
}


func get_entity_tint(entity_key: String, fallback: Color) -> Color:
	if SaveSystem == null:
		return fallback
	var equipped := SaveSystem.get_equipped_cosmetics()
	for slot in equipped.keys():
		var cosmetic_id := str(equipped[slot])
		var overrides: Variant = TINT_OVERRIDES.get(cosmetic_id, {})
		if overrides is Dictionary and overrides.has(entity_key):
			return overrides[entity_key]
	return fallback


func equip_cosmetic(slot: String, cosmetic_id: String) -> void:
	if SaveSystem == null or not StoreService.owns_product(cosmetic_id):
		return
	SaveSystem.set_equipped_cosmetic(slot, cosmetic_id)


func owns_and_can_equip(cosmetic_id: String) -> bool:
	return StoreService != null and StoreService.owns_product(cosmetic_id)
