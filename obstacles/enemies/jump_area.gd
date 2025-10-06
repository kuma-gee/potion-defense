class_name JumpArea
extends Area3D

signal jump_at(pos: Vector3)

@onready var jump_timer_cooldown: Timer = $JumpTimerCooldown

func can_attack():
	return jump_timer_cooldown.is_stopped() and not get_overlapping_bodies().is_empty()

func get_jump_target():
	for body in get_overlapping_bodies():
		if body is Node3D:
			return body.global_position
	return null

func attack():
	var target = get_jump_target()
	if target:
		jump_at.emit(target)
		jump_timer_cooldown.start()
