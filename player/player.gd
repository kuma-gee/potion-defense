class_name Player
extends CharacterBody3D

const GROUP = "player"

signal died()
signal knocked_back(force)

@export var rotation_speed = 10.0

@onready var player_animation: AnimationTree = $PlayerAnimation
@onready var body: Node3D = $BodyRoot
@onready var state_machine: StateMachine = $StateMachine
@onready var dead: State = $StateMachine/Dead
@onready var move: Node = $StateMachine/Move
@onready var stamina: Stamina = $Stamina
@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var health := 5:
	set(v):
		health = v
		print("Player Health: %s" % v)
		if is_dead():
			died.emit()

func _ready() -> void:
	add_to_group(GROUP)
	died.connect(func(): state_machine.change_state(dead))

func is_dead():
	return health <= 0

func is_grounded():
	return is_on_floor()

func hit(from_pos: Vector3, force: float = 10.0):
	if state_machine.current_state != move:
		return

	health -= 1
	var knockback = _get_knockback_direction(from_pos) * force
	knocked_back.emit(knockback)

func _get_knockback_direction(from_pos: Vector3) -> Vector3:
	var dir = (global_position - from_pos).normalized()
	dir.y = 0
	return dir

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	move_and_slide()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

func get_forward_input():
	return _forward(get_input_dir())

func get_input_dir():
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE: return Vector2.ZERO
	return Input.get_vector("move_right", "move_left", "move_down", "move_up")

func _forward(dir: Vector2):
	return (transform.basis.rotated(Vector3.UP, PI) * Vector3(dir.x, 0, dir.y)).normalized()

func rotate_body_to_velocity(delta: float, input_direction: Vector3):
	var is_moving = input_direction.length() > 0.5
	if is_moving and body:
		var velocity_direction = Vector3(velocity.x, 0, velocity.z).normalized()
		var target_transform = body.global_transform.looking_at(body.global_position + velocity_direction, Vector3.UP)
		
		if is_moving_opposite(input_direction, velocity_direction):
			body.global_transform = target_transform
		else:
			body.global_transform = body.global_transform.interpolate_with(target_transform, delta * rotation_speed)

func is_moving_opposite(input: Vector3, vel: Vector3) -> bool:
	if input.length() < 0.1 or vel.length() < 0.1:
		return false

	var input_dir_normalized = input.normalized()
	var velocity_dir_normalized = Vector3(vel.x, 0, vel.z).normalized()
	var dot_product = velocity_dir_normalized.dot(input_dir_normalized)
	return dot_product < -0.3
