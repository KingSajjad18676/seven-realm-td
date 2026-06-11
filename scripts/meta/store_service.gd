extends Node

## Store with gameplay SKUs + cosmetics-first catalog via IapProvider.


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
	"royal_bounty_ticket": {
		"display_name": "Royal Bounty",
		"price_label": "$1.99",
		"type": "consumable",
		"grant_id": "royal_bounty_ticket",
	},
	"ad_removal": {"display_name": "Ad Removal", "price_label": "$3.99", "type": "cosmetic", "grant_id": "ad_removal"},
	"supporter_pack": {
		"display_name": "Supporter Pack",
		"price_label": "$4.99",
		"type": "cosmetic_bundle",
		"grant_ids": ["ad_removal", "supporter_badge", "hud_manuscript_theme"],
	},
	"skin_rostam_nowruz": {
		"display_name": "Rostam Nowruz Skin",
		"price_label": "$1.99",
		"type": "cosmetic",
		"grant_id": "skin_rostam_nowruz",
		"cosmetic_slot": "hero_skin",
	},
	"skin_gate_damavand": {
		"display_name": "Damavand Gate Skin",
		"price_label": "$1.99",
		"type": "cosmetic",
		"grant_id": "skin_gate_damavand",
		"cosmetic_slot": "gate_skin",
	},
	"hud_manuscript_theme": {
		"display_name": "Manuscript HUD Theme",
		"price_label": "$0.99",
		"type": "cosmetic",
		"grant_id": "hud_manuscript_theme",
		"cosmetic_slot": "hud_theme",
	},
}

var _cosmetic_entitlements: Array[String] = []
var _paid_entitlements: Array[String] = []
var _iap: IapProvider = null


func _ready() -> void:
	_iap = _create_iap_provider()
	_iap.purchase_verified.connect(_on_purchase_verified)
	_iap.purchase_failed.connect(_on_purchase_failed)
	_iap.restore_completed.connect(_on_restore_completed)
	_load_entitlements()


func _create_iap_provider() -> IapProvider:
	if OS.has_feature("editor") or OS.is_debug_build():
		return IapProvider.StubIapProvider.new()
	match OS.get_name():
		"Android":
			return IapProvider.GodotBillingProvider.new()
		"iOS":
			return IapProvider.StoreKitProvider.new()
		_:
			return IapProvider.StubIapProvider.new()


func _load_entitlements() -> void:
	if SaveSystem:
		_cosmetic_entitlements = SaveSystem.get_cosmetic_entitlements()
		_paid_entitlements = SaveSystem.get_paid_entitlements()


func get_product_ids() -> Array[String]:
	return get_combat_product_ids() + get_cosmetic_product_ids()


func get_combat_product_ids() -> Array[String]:
	var ids: Array[String] = []
	for product_id in PRODUCTS.keys():
		var ptype := str(PRODUCTS[product_id].get("type", ""))
		if ptype in ["cosmetic", "cosmetic_bundle"]:
			continue
		ids.append(product_id)
	return ids


func get_cosmetic_product_ids() -> Array[String]:
	var ids: Array[String] = []
	for product_id in PRODUCTS.keys():
		var ptype := str(PRODUCTS[product_id].get("type", ""))
		if ptype in ["cosmetic", "cosmetic_bundle"]:
			ids.append(product_id)
	return ids


func get_product(product_id: String) -> Dictionary:
	var product: Variant = PRODUCTS.get(product_id, {})
	return product if product is Dictionary else {}


func owns_product(product_id: String) -> bool:
	if product_id in _paid_entitlements:
		return true
	var product := get_product(product_id)
	if product.is_empty():
		return false
	var ptype := str(product.get("type", ""))
	if ptype == "cosmetic_bundle":
		for grant_id in product.get("grant_ids", []):
			if str(grant_id) not in _cosmetic_entitlements:
				return false
		return true
	var grant_id := str(product.get("grant_id", ""))
	if grant_id != "" and grant_id in _cosmetic_entitlements:
		return true
	return false


func purchase(product_id: String) -> bool:
	var product := get_product(product_id)
	if product.is_empty():
		return false
	if owns_product(product_id):
		return true
	_iap.start_purchase(product_id)
	return owns_product(product_id)


func _on_purchase_verified(product_id: String) -> void:
	_grant_product(product_id)
	AnalyticsService.product_purchased(product_id)
	purchase_completed.emit(product_id)


func _on_purchase_failed(product_id: String, reason: String) -> void:
	if OS.is_debug_build():
		push_warning("StoreService purchase failed %s: %s" % [product_id, reason])


func _grant_product(product_id: String) -> void:
	var product := get_product(product_id)
	if product.is_empty():
		return
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
			var grant := str(product.get("grant_id", ""))
			if grant != "" and grant not in _cosmetic_entitlements:
				_cosmetic_entitlements.append(grant)
			var slot := str(product.get("cosmetic_slot", ""))
			if slot != "" and CosmeticService:
				CosmeticService.equip_cosmetic(slot, grant)
		"cosmetic_bundle":
			for grant_id in product.get("grant_ids", []):
				var gid := str(grant_id)
				if gid not in _cosmetic_entitlements:
					_cosmetic_entitlements.append(gid)
		"consumable":
			if SaveSystem:
				SaveSystem.add_royal_bounty_tickets(1)
		_:
			return
	if product_id not in _paid_entitlements:
		_paid_entitlements.append(product_id)
	_persist()


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


func consume_royal_bounty() -> bool:
	if SaveSystem == null or DailyMissionService == null:
		return false
	if not SaveSystem.consume_royal_bounty_ticket():
		return false
	return DailyMissionService.add_bonus_missions(3)


func restore_purchases() -> void:
	_iap.restore_purchases()


func _on_restore_completed(restored_ids: Array[String]) -> void:
	if restored_ids.is_empty():
		for product_id in get_cosmetic_product_ids():
			if product_id in _paid_entitlements:
				_grant_product(product_id)
				purchase_restored.emit(product_id)
	else:
		for product_id in restored_ids:
			_grant_product(str(product_id))
			purchase_restored.emit(str(product_id))
	_persist()


func _persist() -> void:
	if SaveSystem:
		SaveSystem.set_cosmetic_entitlements(_cosmetic_entitlements)
		SaveSystem.set_paid_entitlements(_paid_entitlements)
