class_name Enemy
extends Character

const GROUP = "Enemy"

@export var spawn_anim := false
@export var target_end := false

@onready var attack_range: RayCast3D = $AttackRange
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var soul_spawner: ObjectSpawner = $SoulSpawner
@onready var move_sound: RandomizedLoopSfx = $MoveSound
@onready var death_sound: RandomizedLoopSfx = $DeathSound
@onready var freeze_timer: Timer = $FreezeTimer
@onready var animation_tree: EnemyAnimationTree = $AnimationTree

var path: Path3D
var current_path_point := 0
var souls := 1

func _ready() -> void:
	super()
	add_to_group(GROUP)

	if spawn_anim:
		animation_tree.spawn()
	else:
		move()
	
	hurt_box.died.connect(func(): _died())
	hurt_box.knockbacked.connect(func(_k): knockback_state())
	animation_tree.animation_finished.connect(func(a): _on_animation_finished(a))
	freeze_timer.timeout.connect(func(): unfreeze())
	
	move_sound.play_randomized()
	if path:
		_update_navigation_target()

func _on_animation_finished(anim: String):
	match animation_tree.state:
		"dead": _on_death_finished()
		"attack": _on_attack_finished(anim)
		"spawn": move()

func _on_death_finished():
	get_tree().create_timer(2.0).timeout.connect(func(): queue_free())

func _on_attack_finished(_anim: String):
	if attack_range.is_colliding():
		animation_tree.attack()
	else:
		animation_tree.move()

func _died():
	died()
	collision_shape_3d.set_deferred("disabled", true)
	var soul = soul_spawner.spawn()
	soul.amount = souls

	death_sound.play_randomized()
	move_sound.stop()

func is_dead():
	return hurt_box.is_dead()

func _physics_process(delta: float) -> void:
	if hurt_box.is_dead():
		return
		
	if not freeze_timer.is_stopped():
		velocity = Vector3.ZERO
		return
	
	match animation_tree.state:
		"knockback":
			apply_knockback(delta)
			if not has_knockback():
				move()
		"move":
			if attack_range.is_colliding():
				attack()
			else:
				_move_to_target()

func _move_to_target():
	if nav_agent.is_navigation_finished():
		if target_end:
			return
		if path and current_path_point < path.curve.point_count:
			current_path_point += 1
			_update_navigation_target()
		return
	
	var sp = get_actual_speed() * Events.enemy_move_speed_multipler
	var next_position = nav_agent.get_next_path_position()
	next_position.y = global_position.y
	var direction = global_position.direction_to(next_position)
	
	velocity.x = direction.x * sp
	velocity.z = direction.z * sp
	
	if direction:
		look_at(global_position + direction, Vector3.UP)

	move_and_slide()
	move()

	var collision = get_last_slide_collision()
	if collision:
		for i in collision.get_collision_count():
			var collider = collision.get_collider(i)
			if collider is WaterCurrent:
				var current: WaterCurrent = collider as WaterCurrent
				var spawn = current.get_closest_spawn(global_position)
				if spawn:
					global_position = spawn.global_transform.origin
					animation_tree.spawn()
				break

func _update_navigation_target():
	if not path or path.curve.point_count == 0:
		return

	if not target_end and current_path_point >= path.curve.point_count:
		return
	
	var target_index := path.curve.point_count - 1 if target_end else current_path_point
	var target_position = path.curve.get_point_position(target_index)
	nav_agent.target_position = target_position

#region STATES
func died():
	animation_tree.active = true
	animation_tree.died()

func freeze(time: float) -> void:
	if hurt_box.is_dead(): return
	move_sound.stop()
	animation_tree.active = false
	freeze_timer.start(time)

func unfreeze():
	animation_tree.active = true
	animation_tree.move()
	move_sound.start()

func attack():
	if hurt_box.is_dead(): return
	animation_tree.attack()
	
func move():
	if hurt_box.is_dead(): return
	animation_tree.active = true
	animation_tree.move()

func knockback_state():
	if hurt_box.is_dead(): return
	animation_tree.knockback()
#endregion STATES
