class_name Enemy
extends Character

const GROUP = "Enemy"

enum State {
	ATTACK,
	MOVE,
	KNOCKBACK,
	DEAD,
}

@export var max_attack_count: int = 3

@onready var attack_range: RayCast3D = $AttackRange
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var soul_spawner: ObjectSpawner = $SoulSpawner
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var state = null
var attack_count := 0
var path: Path3D
var current_path_point := 0

func _ready() -> void:
	super()
	add_to_group(GROUP)

	move()
	hurt_box.died.connect(func(): _died())
	animation_player.animation_finished.connect(func(a): _on_animation_finished(a))
	hurt_box.knockbacked.connect(func(_k): knockback_state())
	
	if path:
		_update_navigation_target()

func _on_animation_finished(anim: String):
	match state:
		State.DEAD: _on_death_finished()
		#State.KNOCKBACK: _on_knockback_finished()
		State.ATTACK: _on_attack_finished(anim)

func _on_knockback_finished():
	move()

func _on_death_finished():
	get_tree().create_timer(2.0).timeout.connect(func(): queue_free())

func _on_attack_finished(_anim: String):
	if attack_range.is_colliding():
		_play_attack()
	else:
		move()

func _died():
	died()
	collision_shape_3d.set_deferred("disabled", true)
	soul_spawner.spawn()

func _physics_process(delta: float) -> void:
	if hurt_box.is_dead():
		return
	
	match state:
		State.KNOCKBACK:
			apply_knockback(delta)
			if not has_knockback():
				_on_knockback_finished()
		State.MOVE:
			if attack_range.is_colliding():
				attack()
			else:
				_move_to_target()

func _move_to_target():
	if nav_agent.is_navigation_finished():
		if path and current_path_point < path.curve.point_count:
			current_path_point += 1
			_update_navigation_target()
		return
	
	var sp = get_actual_speed()
	var next_position = nav_agent.get_next_path_position()
	next_position.y = global_position.y
	var direction = (next_position - global_position).normalized()
	velocity.x = direction.x * sp
	velocity.z = direction.z * sp
	
	if direction:
		look_at(global_position + direction, Vector3.UP)

	move_and_slide()
	move()

func _update_navigation_target():
	if not path or current_path_point >= path.curve.point_count:
		return
	
	var target_position = path.curve.get_point_position(current_path_point)
	nav_agent.target_position = target_position


#region STATES
func died(anim = "death"):
	if state == State.DEAD: return
	state = State.DEAD
	animation_player.play(anim)

func attack():
	if state != State.MOVE: return

	state = State.ATTACK
	_play_attack()

func _play_attack():
	animation_player.play("attack%s" % attack_count)
	
	attack_count += 1
	if attack_count >= max_attack_count:
		attack_count = 0

func move(anim = "move"):
	if state == State.DEAD: return
	state = State.MOVE
	if animation_player.current_animation != anim:
		animation_player.play(anim)

func knockback_state():
	if state == State.DEAD or state == State.KNOCKBACK: return
	state = State.KNOCKBACK
	animation_player.play("knockback")
#endregion STATES
