extends Area3D

signal finished()

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func start():
	animation_player.play("start")
	animation_player.animation_finished.connect(func(a):
		if a == "start":
			finished.emit()
	)
