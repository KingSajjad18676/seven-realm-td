extends Node

## Store with deterministic gameplay SKUs (tower, spells, token packs) + cosmetic entitlements.


signal purchase_completed(product_id: String)
signal purchase_restored(product_id: String)

const PRODUCTS: Dictionary = {
	"tower_zahhak_serpent": {
		"display_name": "Serpent Spire Tower",
		"price_label": "$4.99",
		"type": "tower",
		"grant_id": "tower_zahhak_serpent",
	},
	"tower_rostam_barracks": {
		"display_name": "Rostam Tahmtan Barracks",
		"price_label": "$4.99",
		"type": "tower",
		"grant_id": "tower_rostam_barracks",
	},
	"spell_gold_rush": {"display_name": "Gold Rush Spell", "price_label": "$1.99", "type": "spell", "grant_id": "spell_gold_rush"},
	"spell_purify_blast": {"display_name": "Purify Blast Spell", "price_label": "$2.99", "type": "spell", "grant_id": "spell_purify_blast"},
	"spell_morale_surge": {"display_name": "Morale Surge Spell", "price_label": "$2.99", "type": "spell", "grant_id": "spell_morale_surge"},
	"spell_fire_storm": {"display_name": "Fire Storm Spell", "price_label": "$4.99", "type": "spell", "grant_id": "spell_fire_storm"},
	"spell_tower_overcharge": {"display_name": "Tower Overcharge Spell", "price_label": "$4.99", "type": "spell", "grant_id": "spell_tower_overcharge"},
	"spell_serpent_bane": {"display_name": "Serpent Bane Spell", "price_label": "$6.99", "type": "spell", "grant_id": "spell_serpent_bane"},
	"forge_token_pack_small": {"display_name": "Forge Token Pack (50)", "price_label": "$2.99", "type": "tokens", "amount": 50},
	"forge_token_pack_large": {"display_name": "Forge Token Pack (200)", "price_label": "$9.99", "type": "tokens", "amount": 200},
	"ad_removal": {"display_name": "Ad Removal", "price_label": "$3.99", "type": "cosmetic", "grant_id": "ad_removal"},
}

var _cosmetic_entitlements: Array[String] = []
var _paid_entitlements: Array[String] = []


func _ready() -> void:
	_load_entitlements()


func _load_entitlements() -> void:
	if SaveSystem:
		_cosmetic_entitlements = SaveSystem.get_cosmetic_entitlements()
		_paid_entitlements = SaveSystem.get_paid_entitlements()


func get_product_ids() -> Array[String]:
	var ids: Array[String] = []
	for product_id in PRODUCTS.keys():
		ids.append(product_id)
	return ids


func get_product(product_id: String) -> Dictionary:
	var product: Variant = PRODUCTS.get(product_id, {})
	return product if product is Dictionary else {}


func owns_product(product_id: String) -> bool:
	return product_id in _cosmetic_entitlements or product_id in _paid_entitlements


func purchase(product_id: String) -> bool:
	var product := get_product(product_id)
	if product.is_empty():
		return false
	if owns_product(product_id):
		return true
	match str(product.get("type", "")):
		"tower":
			if SaveSystem:
				SaveSystem.unlock_tower(str(product.get("grant_id", "")))
		"spell":
			if SaveSystem:
				SaveSystem.add_spell(str(product.get("grant_id", "")))
		"tokens":
			if SaveSystem:
				SaveSystem.add_forge_tokens(int(product.get("amount", 0)))
		"cosmetic":
			if str(product.get("grant_id", "")) not in _cosmetic_entitlements:
				_cosmetic_entitlements.append(str(product.get("grant_id", "")))
		_:
			return false
	if product_id not in _paid_entitlements:
		_paid_entitlements.append(product_id)
	_persist()
	purchase_completed.emit(product_id)
	return true


func buy_spell_with_tokens(spell_id: String) -> bool:
	if SaveSystem == null or ContentRegistry == null:
		return false
	if SaveSystem.owns_spell(spell_id):
		return true
	var spell := ContentRegistry.get_spell(spell_id)
	if spell == null:
		return false
	if not SaveSystem.spend_forge_tokens(spell.forge_token_cost):
		return false
	SaveSystem.add_spell(spell_id)
	return true


func restore_purchases() -> void:
	if not owns_product("ad_removal"):
		_cosmetic_entitlements.append("ad_removal")
	_persist()
	purchase_restored.emit("ad_removal")


func _persist() -> void:
	if SaveSystem:
		SaveSystem.set_cosmetic_entitlements(_cosmetic_entitlements)
		SaveSystem.set_paid_entitlements(_paid_entitlements)
