class_name GauntletGhostController
extends RefCounted

const AHEAD_COLOR := Color(0.45, 0.95, 0.55)
const BEHIND_COLOR := Color(0.95, 0.4, 0.4)


static func format_time_ms(ms: int) -> String:
	var total_sec := maxf(0.0, float(ms) / 1000.0)
	var minutes := int(total_sec / 60)
	var seconds := int(total_sec) % 60
	var millis := int(ms) % 1000
	return "%02d:%02d.%03d" % [minutes, seconds, millis]


static func format_delta_sec(delta_ms: int) -> String:
	var sec := absf(float(delta_ms) / 1000.0)
	var sign_prefix := "-" if delta_ms < 0 else "+"
	return "%s%.1fs" % [sign_prefix, sec]


static func delta_vs_pb(elapsed_ms: int, pb: Dictionary) -> int:
	var pb_ms := int(pb.get("total_ms", 0))
	if pb_ms <= 0:
		return 0
	return elapsed_ms - pb_ms


static func ghost_labour_progress(elapsed_ms: int, pb: Dictionary) -> float:
	var splits: Variant = pb.get("splits_ms", [])
	if not splits is Array or splits.is_empty():
		return 0.0
	var labour_count := GauntletRunState.GAUNTLET_LEVEL_IDS.size()
	var ghost_labour := 0
	for i in splits.size():
		if elapsed_ms >= int(splits[i]):
			ghost_labour = i + 1
	var fraction := 0.0
	if ghost_labour < splits.size():
		var prev_ms := int(splits[ghost_labour - 1]) if ghost_labour > 0 else 0
		var next_ms := int(splits[ghost_labour])
		var span := maxi(1, next_ms - prev_ms)
		fraction = clampf(float(elapsed_ms - prev_ms) / float(span), 0.0, 1.0)
	elif ghost_labour >= labour_count:
		return float(labour_count)
	return float(ghost_labour) + fraction


static func ghost_wave_hint(elapsed_ms: int, pb: Dictionary) -> Dictionary:
	var trace: Variant = pb.get("trace", [])
	if not trace is Array:
		return {}
	var best: Dictionary = {}
	for entry in trace:
		if not entry is Dictionary:
			continue
		var t_ms := int(entry.get("t_ms", 0))
		if t_ms <= elapsed_ms:
			best = entry
	return best
