class_name ShrineNodeController
extends Control

signal relic_slotted(tower_id: String, relic_id: String)
signal companion_picked(companion_id: String)
signal cancelled

var _picker: RelicSlotPickerController = null
var _companion_picker: CompanionPickController = null
var _pending_tower_ids: Array[String] = []
var _pending_slots: Dictionary = {}


func _ready() -> void:
	visible = false
	_companion_picker = CompanionPickController.new()
	_companion_picker.name = "CompanionPicker"
	add_child(_companion_picker)
	_companion_picker.companion_picked.connect(_on_companion_picked)
	_companion_picker.skipped.connect(_on_companion_skipped)
	_picker = RelicSlotPickerController.new()
	_picker.name = "RelicPicker"
	add_child(_picker)
	_picker.relic_slotted.connect(_on_relic_slotted)
	_picker.cancelled.connect(_on_picker_cancelled)


func show_shrine_pick(
	tower_ids: Array[String],
	slots: Dictionary,
	active_companion_id: String = ""
) -> void:
	visible = true
	_pending_tower_ids = tower_ids.duplicate()
	_pending_slots = slots.duplicate()
	if active_companion_id == "":
		_companion_picker.show_pick(active_companion_id)
	else:
		_companion_picker.visible = false
		_open_relic_picker()


func _open_relic_picker() -> void:
	_picker.show_pick(_pending_tower_ids, _pending_slots, "Shrine — Relics of the Shahs")


func _on_companion_picked(companion_id: String) -> void:
	companion_picked.emit(companion_id)
	_open_relic_picker()


func _on_companion_skipped() -> void:
	_open_relic_picker()


func _on_relic_slotted(tower_id: String, relic_id: String) -> void:
	visible = false
	relic_slotted.emit(tower_id, relic_id)


func _on_picker_cancelled() -> void:
	visible = false
	cancelled.emit()
