class_name GauntletTimerController
extends Node

var context: BattleContext = null
var hud_widget: GauntletHudWidget = null

var _wave_conn: Callable


func initialize(ctx: BattleContext, widget: GauntletHudWidget) -> void:
	context = ctx
	hud_widget = widget
	_wave_conn = _on_wave_started
	if not CombatEvents.wave_started.is_connected(_wave_conn):
		CombatEvents.wave_started.connect(_wave_conn)
	if hud_widget:
		hud_widget.setup(_get_run(), SaveSystem.get_gauntlet_best() if SaveSystem else {})


func _exit_tree() -> void:
	if CombatEvents.wave_started.is_connected(_wave_conn):
		CombatEvents.wave_started.disconnect(_wave_conn)


func _process(_delta: float) -> void:
	if hud_widget == null:
		return
	var run := _get_run()
	if run == null:
		return
	var elapsed := run.get_elapsed_ms()
	var pb := SaveSystem.get_gauntlet_best() if SaveSystem else {}
	hud_widget.refresh(elapsed, run.labour_index, pb)


func get_elapsed_ms() -> int:
	var run := _get_run()
	if run == null:
		return 0
	return run.get_elapsed_ms()


func pause_timer() -> void:
	var run := _get_run()
	if run:
		run.pause_timer()


func resume_timer() -> void:
	var run := _get_run()
	if run:
		run.resume_timer()


func _on_wave_started(wave_index: int) -> void:
	var run := _get_run()
	if run == null:
		return
	run.record_trace_sample(run.get_elapsed_ms(), wave_index)


func _get_run() -> GauntletRunState:
	if SceneFlowController and SceneFlowController.pending_gauntlet_run:
		return SceneFlowController.pending_gauntlet_run
	return null
