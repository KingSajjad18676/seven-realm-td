extends Node

var _breadcrumbs: Array[String] = []
var _backend: CrashBackend = null
const MAX_BREADCRUMBS := 32


func _ready() -> void:
	_backend = _create_backend()


func _create_backend() -> CrashBackend:
	if OS.is_debug_build():
		return CrashBackend.FileCrashBackend.new()
	var url := str(ProjectSettings.get_setting("shahnameh/crash_url", ""))
	if url != "":
		return CrashBackend.HttpCrashBackend.new(url)
	return CrashBackend.FileCrashBackend.new()


func add_breadcrumb(message: String) -> void:
	_breadcrumbs.append(message)
	while _breadcrumbs.size() > MAX_BREADCRUMBS:
		_breadcrumbs.pop_front()


func report_error(message: String, context_fields: Dictionary = {}) -> void:
	var fields := context_fields.duplicate()
	fields["breadcrumbs"] = _breadcrumbs.duplicate()
	fields["stack"] = _capture_stack()
	if OS.is_debug_build():
		push_warning("[CrashReporter] %s %s" % [message, fields])
	if _backend:
		_backend.report_error(message, fields)
	if SaveSystem and SaveSystem.get_analytics_consent():
		AnalyticsService.track_event("crash_report", {"message": message, "fields": fields})


func _capture_stack() -> Array[String]:
	var lines: Array[String] = []
	for frame in get_stack():
		lines.append(frame)
	return lines
