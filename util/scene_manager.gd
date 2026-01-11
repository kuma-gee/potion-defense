extends Node

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func transition(callback: Callable):
	animation_player.play("show")
	await callback.call()
	animation_player.play_backwards("show")
