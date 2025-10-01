extends Area3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func start():
	animation_player.play("start")

func hit():
	for b in get_overlapping_bodies():
		b.hit(global_position)
