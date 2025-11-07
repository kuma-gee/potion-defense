class_name Enemy
extends CharacterBody3D

const GROUP = "Enemy"

@export var speed := 1.0
@export var attack_anims: Array[String] = []
@export var run_anim := "Walking_D_Skeletons"
@export var death_anim := "Death_C_Skeletons"
@export var hit_box: HitBox
@export var animation_player: AnimationPlayer
@export var hurt_box: HurtBox
@export var knockback_resistance := 5.0
@export var projectile_spawn: SpawnAttack

# Animation Tree doesnt work?
var is_attacking := false
var knockback: Vector3
var resource: EnemyResource

func _ready() -> void:
	add_to_group(GROUP)
	animation_player.animation_finished.connect(func(a):
		if a == death_anim:
			get_tree().create_timer(2.0).timeout.connect(func(): queue_free())
			return
		
		if a in attack_anims:
			if resource.projectile:
				projectile_spawn.spawn(resource.projectile)
			else:
				hit_box.hit()
			is_attacking = false
	)
	hurt_box.knockbacked.connect(func(x): knockback = x)
	hurt_box.died.connect(func(): animation_player.play(death_anim))

	speed = resource.speed
	hit_box.damage = resource.damage
	hurt_box.set_max_health(resource.health)
	
func _physics_process(delta: float) -> void:
	if hurt_box.is_dead():
		return
	
	# Apply knockback if present
	var has_knockback = knockback.length() > 0.01
	if has_knockback:
		# Project knockback onto the global_basis.z direction
		var knockback_dir = global_basis.z.normalized()
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
	animation_player.play(run_anim)

func take_damage(dmg: int):
	hurt_box.health -= dmg
