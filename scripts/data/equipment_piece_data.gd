class_name EquipmentPieceData
extends Resource

enum SlotType { WEAPON, ARMOR, HELM, TALISMAN }
enum DropSource { KHAN_BOSS, DAILY_MISSION }

@export var piece_id: String = ""
@export var display_name: String = ""
@export var set_id: String = ""
@export var slot_type: SlotType = SlotType.WEAPON
@export var drop_source: DropSource = DropSource.KHAN_BOSS
@export var drop_level_id: String = ""
@export var stat_modifiers: Dictionary = {}
@export var icon_path: String = ""


static func slot_key(slot: SlotType) -> String:
	match slot:
		SlotType.WEAPON:
			return "weapon"
		SlotType.ARMOR:
			return "armor"
		SlotType.HELM:
			return "helm"
		SlotType.TALISMAN:
			return "talisman"
	return ""


func is_daily_drop() -> bool:
	return drop_source == DropSource.DAILY_MISSION


func is_boss_drop() -> bool:
	return drop_source == DropSource.KHAN_BOSS
