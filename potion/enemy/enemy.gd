class_name Enemy
extends CharacterBody3D

@export var speed := 3.0
@export var attack_anims: Array[String] = []
@export var hit_box: HitBox
@export var animation_player: AnimationPlayer
@export var hurt_box: HurtBox
@export var knockback_resistance := 5.0

# Animation Tree doesnt work?
var is_attacking := false
var knockback: Vector3

func _ready() -> void:
	animation_player.animation_finished.connect(func(_a):
		hit_box.hit()
		is_attacking = false
	)
	hurt_box.knockbacked.connect(func(x): knockback = x)
	hurt_box.died.connect(func():
		queue_free()
	)

func _physics_process(delta: float) -> void:
	# Apply knockback if present
	var has_knockback = knockback.length() > 0.01
	if has_knockback:
		# Project knockback onto the global_basis.z direction
		var knockback_dir = -global_basis.z.normalized()
		var knockback_amount = knockback.length()
		velocity = knockback_dir * knockback_amount
		knockback = knockback.lerp(Vector3.ZERO, delta * knockback_resistance)
		move_and_slide()
		return
	
	if hit_box.has_overlapping_areas():
		if not is_attacking:
			animation_player.play(attack_anims.pick_random())
			is_attacking = true
		return
	
	var dir = -global_basis.z.normalized()
	velocity = dir * speed
	move_and_slide()
	animation_player.play("Running_A")
