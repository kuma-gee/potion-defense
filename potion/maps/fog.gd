extends Obstacle

@export var timer: RandomTimer

func _ready() -> void:
	timer.timeout.connect(_deactivate)

func _deactivate():
	hide()
	deactivated.emit()

func activate():
	show()
	activated.emit()
	timer.start_random()
