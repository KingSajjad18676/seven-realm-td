class_name DamageInfo
extends RefCounted

var amount: float = 0.0
var damage_type: GameEnums.DamageType = GameEnums.DamageType.PHYSICAL
var source_tags: Array[String] = []
var applies_burn: bool = false
var applies_slow: bool = false
var armor_break: bool = false


static func create(
	amt: float,
	dtype: GameEnums.DamageType = GameEnums.DamageType.PHYSICAL,
	tags: Array[String] = []
) -> DamageInfo:
	var info := DamageInfo.new()
	info.amount = amt
	info.damage_type = dtype
	info.source_tags = tags
	return info
