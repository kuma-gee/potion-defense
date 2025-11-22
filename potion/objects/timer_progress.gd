extends ProgressBar

@export var timer: Timer

func _ready() -> void:
	value = 0.0
	max_value = 1.0
	
func _process(_d: float) -> void:
	if not timer.is_stopped():
		value = 1.0 - timer.time_left / timer.wait_time
	else:
		value = 0.0
