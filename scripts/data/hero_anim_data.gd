class_name HeroAnimData
extends Resource

@export var portrait_path: String = ""
@export var display_size: Vector2 = Vector2(68, 68)
@export var strips: Array[HeroAnimStripDef] = []


func has_strips() -> bool:
	return not strips.is_empty()


func find_strip(anim_name: String) -> HeroAnimStripDef:
	for strip in strips:
		if strip.anim_name == anim_name:
			return strip
	return null
