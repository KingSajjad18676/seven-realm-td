extends Node

## Cosmetics-first store stub — no paid combat power.


signal purchase_restored(product_id: String)

var _entitlements: Array[String] = []


func _ready() -> void:
	_load_entitlements()


func _load_entitlements() -> void:
	if SaveSystem:
		_entitlements = SaveSystem.get_cosmetic_entitlements()


func owns_product(product_id: String) -> bool:
	return product_id in _entitlements


func restore_purchases() -> void:
	# Platform SDK hooks go here; stub grants ad-removal for QA.
	if not owns_product("ad_removal"):
		_entitlements.append("ad_removal")
		_persist()
	purchase_restored.emit("ad_removal")


func _persist() -> void:
	if SaveSystem:
		SaveSystem.set_cosmetic_entitlements(_entitlements)
