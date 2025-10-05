class_name HitBox
extends Area3D

@export var force := 5.0
@export var hit_delay := 0.5
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D

var is_dodgeable := false

func hit():
	is_dodgeable = true
	gpu_particles_3d.emitting = true
	await get_tree().create_timer(hit_delay).timeout
	
	for b in get_overlapping_bodies():
		if b.has_method("hit"):
			b.hit(global_position, force)
	
	is_dodgeable = false
