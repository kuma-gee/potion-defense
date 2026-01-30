extends Node

signal resource_loaded(path: String, resource: Resource)

var _pending: Dictionary[String, bool] = {}

func _ready() -> void:
	set_process(false)

func request_load(path: String) -> void:
	if path.is_empty():
		return

	if _pending.has(path):
		return

	if ResourceLoader.has_cached(path):
		var cached_resource: Resource = ResourceLoader.load(path)
		resource_loaded.emit(path, cached_resource)
		return

	var result: int = ResourceLoader.load_threaded_request(path)
	if result != OK:
		return

	_pending[path] = true
	set_process(true)

func _process(_delta: float) -> void:
	if _pending.is_empty():
		set_process(false)
		return

	var completed: Array[String] = []
	for path in _pending.keys():
		var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(path)
		if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			var loaded_resource: Resource = ResourceLoader.load_threaded_get(path)
			resource_loaded.emit(path, loaded_resource)
			completed.append(path)
		elif status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
			resource_loaded.emit(path, null)
			completed.append(path)
	
	for path in completed:
		_pending.erase(path)
	
	if _pending.is_empty():
		set_process(false)
