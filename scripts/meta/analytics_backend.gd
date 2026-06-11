class_name AnalyticsBackend
extends RefCounted

func track_event(_event_name: String, _fields: Dictionary) -> void:
	pass


func flush() -> void:
	pass


class FileAnalyticsBackend extends AnalyticsBackend:
	var _path: String = "user://analytics_events.jsonl"

	func track_event(event_name: String, fields: Dictionary) -> void:
		var line := JSON.stringify({
			"event": event_name,
			"fields": fields,
			"time": Time.get_unix_time_from_system(),
		})
		var file := FileAccess.open(_path, FileAccess.READ_WRITE)
		if file == null:
			file = FileAccess.open(_path, FileAccess.WRITE)
		if file:
			file.seek_end()
			file.store_line(line)
			file.close()


class HttpAnalyticsBackend extends AnalyticsBackend:
	var _url: String = ""

	func _init(url: String = "") -> void:
		_url = url

	func track_event(event_name: String, fields: Dictionary) -> void:
		if _url == "":
			return
		var http := HTTPRequest.new()
		var payload := JSON.stringify({"event": event_name, "fields": fields})
		http.request(_url, ["Content-Type: application/json"], HTTPClient.METHOD_POST, payload)
