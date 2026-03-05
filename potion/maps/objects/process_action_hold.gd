class_name ProcessActionHold
extends ProcessAction

@export var duration: float = 3.0
@export var multipler := 1.0
@export var progress_bar: ProgressBar
@export var overheat_timer: Overheat

var pressed := false
var elapsed: float = 0.0:
	set(v):
		elapsed = v
		progress_bar.value = clamp(elapsed / max(duration, 0.001), 0.0, 1.0)

func _ready() -> void:
	if overheat_timer:
		overheat_timer.overheated.connect(func(): fail())

func _on_update(delta: float) -> void:
	if automatic or pressed:
		elapsed += delta * multipler
		if elapsed >= duration:
			if automatic and overheat_timer:
				overheat_timer.start_if_stopped()
			complete()

func _process(delta: float) -> void:
	if overheat_timer:
		overheat_timer.update_overheat(delta)

func _on_action_pressed() -> void:
	pressed = true

func _on_action_released() -> void:
	pressed = false

func on_item_changed(item: ItemResource):
	if item == null:
		elapsed = 0.0
		if overheat_timer:
			overheat_timer.reset()
