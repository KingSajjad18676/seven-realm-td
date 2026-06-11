class_name CrashBackend
extends RefCounted

func report_error(_message: String, _fields: Dictionary) -> void:
	pass


class FileCrashBackend extends CrashBackend:
	func report_error(message: String, fields: Dictionary) -> void:
		var path := "user://crash_reports.jsonl"
		var line := JSON.stringify({
			"message": message,
			"fields": fields,
			"time": Time.get_unix_time_from_system(),
		})
		var file := FileAccess.open(path, FileAccess.READ_WRITE)
		if file == null:
			file = FileAccess.open(path, FileAccess.WRITE)
		if file:
			file.seek_end()
			file.store_line(line)
			file.close()


class HttpCrashBackend extends CrashBackend:
	var _url: String = ""

	func _init(url: String = "") -> void:
		_url = url

	func report_error(message: String, fields: Dictionary) -> void:
		if _url == "":
			return
		var http := HTTPRequest.new()
		var payload := JSON.stringify({"message": message, "fields": fields})
		http.request(_url, ["Content-Type: application/json"], HTTPClient.METHOD_POST, payload)
