class_name LevelAssetPreloader
extends RefCounted

const MIN_DISPLAY_SEC := 0.35


static func preload_paths(paths: PackedStringArray, on_progress: Callable = Callable()) -> bool:
	var start_ms := Time.get_ticks_msec()
	var total := paths.size()
	var completed := 0

	for path in paths:
		if path == "" or not ResourceLoader.exists(path):
			completed += 1
			_emit_progress(on_progress, completed, total)
			continue

		if ResourceLoader.has_cached(path):
			completed += 1
			_emit_progress(on_progress, completed, total)
			continue

		var err := ResourceLoader.load_threaded_request(path)
		if err != OK:
			push_warning("LevelAssetPreloader: failed to request %s (err %d)" % [path, err])
			completed += 1
			_emit_progress(on_progress, completed, total)
			continue

		while true:
			var status := ResourceLoader.load_threaded_get_status(path)
			if status == ResourceLoader.THREAD_LOAD_LOADED:
				var res = ResourceLoader.load_threaded_get(path)
				if res == null:
					push_warning("LevelAssetPreloader: null resource for %s" % path)
				break
			if status == ResourceLoader.THREAD_LOAD_FAILED:
				push_warning("LevelAssetPreloader: load failed for %s" % path)
				break
			if status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				push_warning("LevelAssetPreloader: invalid resource %s" % path)
				break
			await Engine.get_main_loop().process_frame

		completed += 1
		_emit_progress(on_progress, completed, total)

	var elapsed_sec := (Time.get_ticks_msec() - start_ms) / 1000.0
	if elapsed_sec < MIN_DISPLAY_SEC:
		await Engine.get_main_loop().create_timer(MIN_DISPLAY_SEC - elapsed_sec).timeout

	return true


static func _emit_progress(on_progress: Callable, completed: int, total: int) -> void:
	if not on_progress.is_valid():
		return
	var ratio := 1.0 if total <= 0 else float(completed) / float(total)
	on_progress.call(ratio)
