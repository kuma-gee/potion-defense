class_name Enemy
extends Character

const GROUP = "Enemy"

@export var attack_anims: Array[String] = []
@export var run_anim := "Walking_D_Skeletons"
@export var death_anim := "Death_C_Skeletons"
@export var hit_box: HitBox
@export var animation_player: AnimationPlayer
@export var projectile_spawn: SpawnAttack

# Animation Tree doesnt work?
var is_attacking := false
var resource: EnemyResource

func _ready() -> void:
	super()
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
	hurt_box.died.connect(func(): animation_player.play(death_anim))

	speed = resource.speed
	hit_box.damage = resource.damage
	hurt_box.set_max_health(resource.health)

func get_original_speed():
	return resource.speed

func _physics_process(delta: float) -> void:
	if hurt_box.is_dead():
		return
	
	if apply_knockback(delta):
		return

	if hit_box.has_overlapping_areas():
		if not is_attacking:
			animation_player.play(attack_anims.pick_random())
			is_attacking = true
		return

	var dir = -global_basis.z.normalized()
	velocity = dir * get_actual_speed()
	move_and_slide()
	animation_player.play(run_anim)

func take_damage(dmg: int):
	hurt_box.health -= dmg

func get_knockback_force(knock: Vector3) -> Vector3:
	return global_basis.z.normalized() * knock.length()
