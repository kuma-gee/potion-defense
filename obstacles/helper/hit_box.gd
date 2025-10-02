class_name HitBox
extends Area3D

@export var force := 0.0

func hit():
	for b in get_overlapping_bodies():
		b.hit(global_position, force)
