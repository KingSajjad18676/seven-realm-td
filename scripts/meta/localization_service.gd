extends Node

const STRINGS: Dictionary = {
	"menu_play": "Play Campaign",
	"menu_forge": "Kaveh's Forge",
	"menu_settings": "Settings",
	"battle_gold": "Gold",
	"battle_sacred_fire": "Sacred Fire",
	"battle_farr": "Farr",
	"world_map_title": "Seven Labours of Rostam",
	"simorgh_title": "Simorgh's Feather",
	"simorgh_body": "Once per run: clear the field and restore 3 lives?",
	"simorgh_accept": "Accept",
	"simorgh_decline": "Decline",
	"store_combat_tab": "Combat",
	"store_cosmetics_tab": "Cosmetics",
	"privacy_title": "Privacy & Data",
	"privacy_body": "We use optional analytics to improve the game. You can change this later in Settings.",
	"privacy_analytics": "Share anonymous gameplay analytics",
	"privacy_policy": "Privacy Policy",
	"privacy_terms": "Terms of Service",
	"privacy_continue": "Continue",
	"settings_privacy": "Privacy & data",
}


func tr_key(key: String) -> String:
	return STRINGS.get(key, key)
