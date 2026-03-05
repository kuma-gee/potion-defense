class_name Overheat
extends Timer

signal overheated
signal overheating_changed(value: bool)
signal overheat_changed(value: float)

@export var progress: Range
@export var max_overheat := 6.0:
	set(value):
		max_overheat = max(value, 0.001)
		if progress:
			progress.max_value = max_overheat
@export var cooldown_multiplier := -1.0

var overheat := 0.0:
	set(value):
		overheat = clamp(value, 0.0, max_overheat)
		if progress:
			progress.value = overheat
		overheat_changed.emit(overheat)

var overheating := false:
	set(value):
		if overheating == value:
			return
		overheating = value
		overheating_changed.emit(overheating)

func _ready() -> void:
	timeout.connect(_on_start_timeout)

	max_overheat = max_overheat
	overheat = 0.0
	overheating = false

func _on_start_timeout() -> void:
	overheating = true

func _on_overheated() -> void:
	overheating = false
	overheated.emit()

func update_overheat(delta: float, is_cooling: bool = false) -> void:
	if not overheating:
		return

	var direction: float = 1.0 if not is_cooling else cooldown_multiplier
	overheat += delta * direction
	if overheat >= max_overheat:
		overheat = max_overheat
		_on_overheated()
	elif overheat <= 0.0:
		overheat = 0.0
		overheating = false

func reset() -> void:
	stop()
	overheat = 0.0
	overheating = false

func start_if_stopped() -> void:
	if overheating or not is_stopped():
		return
	start()
