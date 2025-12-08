extends ProgressBar

@export var timer: Timer
@export var hide_on_stop := false
@export var reset_on_stopped := false

func _ready() -> void:
	value = 0.0
	max_value = 1.0
	
func _process(_d: float) -> void:
	if hide_on_stop:
		visible = not timer.is_stopped()
	
	if timer and not timer.is_stopped():
		value = 1.0 - timer.time_left / timer.wait_time
	else:
		if reset_on_stopped:
			value = 0.0
