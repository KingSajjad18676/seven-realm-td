extends Node

var _session_events: Array[Dictionary] = []


func track_event(event_name: String, fields: Dictionary = {}) -> void:
	var entry := {
		"event": event_name,
		"fields": fields,
		"time": Time.get_unix_time_from_system(),
	}
	_session_events.append(entry)
	if OS.is_debug_build():
		print("[Analytics] ", event_name, " ", fields)


func session_start() -> void:
	track_event("session_start")


func battle_started(level_id: String) -> void:
	track_event("battle_started", {"level_id": level_id})


func battle_completed(victory: bool, level_id: String) -> void:
	track_event("battle_completed", {"victory": victory, "level_id": level_id})


func replay_selected(level_id: String) -> void:
	track_event("replay_selected", {"level_id": level_id})


func fate_card_selected(card_id: String) -> void:
	track_event("fate_card_selected", {"card_id": card_id})


func region_state_changed(region_id: String, state: int) -> void:
	track_event("region_state_changed", {"region_id": region_id, "state": state})


func tower_hijack_started(spot_id: String) -> void:
	track_event("tower_hijack_started", {"spot_id": spot_id})


func tower_hijack_recovered(spot_id: String) -> void:
	track_event("tower_hijack_recovered", {"spot_id": spot_id})


func cleanse_used(region_id: String) -> void:
	track_event("cleanse_used", {"region_id": region_id})


func pardeh_break_opened(level_id: String) -> void:
	track_event("pardeh_break_opened", {"level_id": level_id})


func objective_completed(objective_id: String, success: bool) -> void:
	track_event("objective_completed", {"objective_id": objective_id, "success": success})


func roguelite_node_selected(node_type: String) -> void:
	track_event("roguelite_node_selected", {"node_type": node_type})


func tower_upgraded(tower_id: String, new_level: int) -> void:
	track_event("tower_upgraded", {"tower_id": tower_id, "level": new_level})


func tower_sold(tower_id: String, refund: int) -> void:
	track_event("tower_sold", {"tower_id": tower_id, "refund": refund})


func battle_exit_to_map(level_id: String, victory: bool) -> void:
	track_event("battle_exit_to_map", {"level_id": level_id, "victory": victory})


func gauntlet_started() -> void:
	track_event("gauntlet_started", {})


func gauntlet_completed(total_ms: int) -> void:
	track_event("gauntlet_completed", {"total_ms": total_ms})


func gauntlet_pb_beaten(total_ms: int) -> void:
	track_event("gauntlet_pb_beaten", {"total_ms": total_ms})


func get_buffered_events() -> Array[Dictionary]:
	return _session_events.duplicate()
