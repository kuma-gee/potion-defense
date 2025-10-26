class_name HitBox
extends Area3D

@export var damage := 1
@export var force := 0
@export var on_init := false

func _ready() -> void:
	if on_init:
		await get_tree().create_timer(0.1).timeout
		hit()

func hit():
	for b in get_overlapping_areas():
		if b.has_method("hit"):
			var dir = global_position.direction_to(b.global_position)
			b.hit(damage, dir * force)
			if on_init:
				print(b)
