extends Obstacle

@export var timer: RandomTimer
@export var animation: AnimationPlayer
@export var anim_name := "start"

func _ready() -> void:
	timer.timeout.connect(_deactivate)

func _deactivate():
	animation.play_backwards(anim_name)
	deactivated.emit()

func activate():
	activated.emit()
	timer.start_random()
	animation.play(anim_name)
