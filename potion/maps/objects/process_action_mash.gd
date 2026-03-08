class_name ProcessActionMash
extends ProcessAction

@export var required_presses: int = 20
@export var progress_bar: ProgressBar
@export var sfx: RandomizedLoopSfx

var presses: int = 0:
	set(v):
		presses = v
		progress_bar.value = clamp(float(presses) / max(float(required_presses), 1.0), 0.0, 1.0)

func on_item_changed(_item: ItemResource) -> void:
	presses = 0

func _on_action_pressed() -> void:
	sfx.start()
	presses += 1
	if presses >= required_presses:
		complete()
