class_name GauntletRunState
extends RefCounted

const GAUNTLET_LEVEL_IDS: Array[String] = [
	"level_01", "level_02", "level_03", "level_04",
	"level_05", "level_06", "level_07",
]

var labour_index: int = 0
var run_tower_ids: Array[String] = []
var started_at_ms: int = 0
var splits_ms: Array[int] = []
var trace: Array[Dictionary] = []
var _paused_accum_ms: int = 0
var _pause_started_ms: int = -1


func start_run(tower_ids: Array[String]) -> void:
	labour_index = 0
	run_tower_ids = tower_ids.duplicate()
	started_at_ms = Time.get_ticks_msec()
	splits_ms.clear()
	trace.clear()
	_paused_accum_ms = 0
	_pause_started_ms = -1


func current_level_id() -> String:
	if labour_index < 0 or labour_index >= GAUNTLET_LEVEL_IDS.size():
		return GAUNTLET_LEVEL_IDS[0]
	return GAUNTLET_LEVEL_IDS[labour_index]


func is_complete() -> bool:
	return labour_index >= GAUNTLET_LEVEL_IDS.size()


func record_labour_clear(elapsed_ms: int) -> void:
	splits_ms.append(elapsed_ms)


func record_trace_sample(elapsed_ms: int, wave_index: int) -> void:
	trace.append({
		"t_ms": elapsed_ms,
		"labour": labour_index,
		"wave": wave_index,
	})


func advance_labour() -> void:
	labour_index += 1


func get_elapsed_ms() -> int:
	var now := Time.get_ticks_msec()
	var pause_extra := 0
	if _pause_started_ms >= 0:
		pause_extra = now - _pause_started_ms
	return maxi(0, now - started_at_ms - _paused_accum_ms - pause_extra)


func pause_timer() -> void:
	if _pause_started_ms < 0:
		_pause_started_ms = Time.get_ticks_msec()


func resume_timer() -> void:
	if _pause_started_ms >= 0:
		_paused_accum_ms += Time.get_ticks_msec() - _pause_started_ms
		_pause_started_ms = -1


func to_dict() -> Dictionary:
	return {
		"labour_index": labour_index,
		"run_tower_ids": run_tower_ids.duplicate(),
		"started_at_ms": started_at_ms,
		"splits_ms": splits_ms.duplicate(),
		"trace": trace.duplicate(true),
		"paused_accum_ms": _paused_accum_ms,
	}


static func from_dict(data: Dictionary) -> GauntletRunState:
	var state := GauntletRunState.new()
	state.labour_index = int(data.get("labour_index", 0))
	state.run_tower_ids.assign(data.get("run_tower_ids", []))
	state.started_at_ms = int(data.get("started_at_ms", Time.get_ticks_msec()))
	var splits: Variant = data.get("splits_ms", [])
	if splits is Array:
		for s in splits:
			state.splits_ms.append(int(s))
	var tr: Variant = data.get("trace", [])
	if tr is Array:
		for entry in tr:
			if entry is Dictionary:
				state.trace.append(entry.duplicate())
	state._paused_accum_ms = int(data.get("paused_accum_ms", 0))
	return state


func build_launch() -> BattleLaunchData:
	var launch := BattleLaunchData.new()
	launch.level_id = current_level_id()
	launch.is_gauntlet_mode = true
	launch.gauntlet_labour_index = labour_index
	launch.run_tower_ids = run_tower_ids.duplicate()
	return launch
