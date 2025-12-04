class_name Enemy
extends Character

const GROUP = "Enemy"
const SOUL = preload("uid://c0rmnm1ehb0qg")

@export var attack_anims: Array[String] = []
@export var run_anim := "Walking_D_Skeletons"
@export var death_anim := "Death_C_Skeletons"
@export var hit_box: HitBox
@export var animation_player: AnimationPlayer
@export var projectile_spawn: SpawnAttack

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

# Animation Tree doesnt work?
var is_attacking := false
var resource: EnemyResource

func _ready() -> void:
	super()
	add_to_group(GROUP)

	hurt_box.died.connect(func(): _died())
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

	speed = resource.speed
	hit_box.damage = resource.damage
	hurt_box.set_max_health(resource.health)

func _died():
	animation_player.play(death_anim)
	collision_shape_3d.set_deferred("disabled", true)
	_spawn_soul()

func _spawn_soul():
	var node = SOUL.instantiate()
	node.position = global_position
	get_tree().current_scene.add_child(node)

func set_target(pos: Vector3):
	nav_agent.target_position = pos

func get_original_speed():
	return resource.speed

func _physics_process(delta: float) -> void:
	if hurt_box.is_dead():
		return
	
	if apply_knockback(delta):
		return

	if hit_box.can_hit():
		if not is_attacking:
			animation_player.play(attack_anims.pick_random())
			is_attacking = true
		return

	if nav_agent.is_navigation_finished():
		return
	
	var sp = get_actual_speed()
	var next_position = nav_agent.get_next_path_position()
	next_position.y = global_position.y
	var direction = (next_position - global_position).normalized()
	velocity.x = direction.x * sp
	velocity.z = direction.z * sp
	
	if direction:
		look_at(global_position + direction, Vector3.UP)

	#var dir = -global_basis.z.normalized()
	#velocity = dir * get_actual_speed()
	move_and_slide()
	animation_player.play(run_anim)

func take_damage(dmg: int):
	hurt_box.health -= dmg

func get_knockback_force(knock: Vector3) -> Vector3:
	return global_basis.z.normalized() * knock.length()
