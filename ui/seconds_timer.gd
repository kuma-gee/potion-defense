class_name SecondsTimer
extends Label

@export var timer: Timer

func _process(_delta: float) -> void:
	visible = not timer.is_stopped()
	text = "%.0fs" % timer.time_left
