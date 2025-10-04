class_name HitBox
extends Area3D

@export var force := 5.0

func hit():
	for b in get_overlapping_bodies():
		if b.has_method("hit"):
			b.hit(global_position, force)
