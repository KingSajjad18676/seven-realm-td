extends Node

const STRINGS: Dictionary = {
	"menu_play": "Play Campaign",
	"menu_forge": "Kaveh's Forge",
	"menu_settings": "Settings",
	"battle_gold": "Gold",
	"battle_sacred_fire": "Sacred Fire",
	"world_map_title": "Seven Khans",
}


func tr_key(key: String) -> String:
	return STRINGS.get(key, key)
