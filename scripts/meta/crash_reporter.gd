extends Node

## Crash reporting stub — wire to platform SDK at soft launch.


func report_error(message: String, context_fields: Dictionary = {}) -> void:
	if OS.is_debug_build():
		push_warning("[CrashReporter] %s %s" % [message, context_fields])
	AnalyticsService.track_event("crash_report", {"message": message, "fields": context_fields})
