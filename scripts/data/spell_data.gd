class_name SpellData
extends Resource

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	LEGENDARY,
}

@export var spell_id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var rarity: Rarity = Rarity.COMMON
@export var forge_token_cost: int = 25
@export var cooldown_seconds: float = 30.0
@export var effect_type: String = ""
@export var effect_value: float = 0.0
@export var store_product_id: String = ""


func rarity_label() -> String:
	match rarity:
		Rarity.UNCOMMON:
			return "Uncommon"
		Rarity.RARE:
			return "Rare"
		Rarity.LEGENDARY:
			return "Legendary"
		_:
			return "Common"
