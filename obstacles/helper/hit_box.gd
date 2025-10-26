class_name HitBox
extends Area3D

@export var damage := 1

func hit():
	for b in get_overlapping_areas():
		if b.has_method("hit"):
			b.hit(damage)
