class_name PlayerMovement
extends Node

@export var default_speed = 5.0
@export var sprint_speed = 8.0
@export var jump_vel = 4.
@export var acceleration = 15.0
@export var deceleration = 20.0
@export var rotation_speed = 10.0

@export var body: Node3D

@onready var player: CharacterBody3D = get_parent()
@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	if player.is_dead():
		return

	var direction = get_forward_input()
	var speed = sprint_speed if Input.is_action_pressed("sprint") else default_speed

	if player.is_grounded():
		if direction:
			player.velocity.x = lerp(player.velocity.x, direction.x * speed, delta * acceleration)
			player.velocity.z = lerp(player.velocity.z, direction.z * speed, delta * acceleration)
		else:
			player.velocity.x = lerp(player.velocity.x, 0.0, delta * deceleration)
			player.velocity.z = lerp(player.velocity.z, 0.0, delta * deceleration)
	else:
		if direction:
			player.velocity.x = lerp(player.velocity.x, direction.x * speed, delta * acceleration * 0.2)
			player.velocity.z = lerp(player.velocity.z, direction.z * speed, delta * acceleration * 0.2)
		else:
			player.velocity.x = lerp(player.velocity.x, 0.0, delta * deceleration * 0.1)
			player.velocity.z = lerp(player.velocity.z, 0.0, delta * deceleration * 0.1)

	apply_gravity(delta)
	player.move_and_slide()

	rotate_body_to_velocity(delta, direction)

func get_forward_input():
	return _forward(get_input_dir())

func get_input_dir():
	return Input.get_vector("move_right", "move_left", "move_down", "move_up")

func _forward(dir: Vector2):
	return (player.transform.basis.rotated(Vector3.UP, PI) * Vector3(dir.x, 0, dir.y)).normalized()

func apply_gravity(delta):
	if not player.is_on_floor():
		player.velocity.y -= gravity * delta
	else:
		player.velocity.y = 0

func rotate_body_to_velocity(delta: float, input_direction: Vector3):
	var is_moving = player.velocity.length() > 0.5
	if is_moving and body:
		var velocity_direction = Vector3(player.velocity.x, 0, player.velocity.z).normalized()
		var target_transform = body.transform.looking_at(body.global_position + velocity_direction, Vector3.UP)
		
		if is_moving_opposite(input_direction, velocity_direction):
			body.transform = target_transform
		else:
			body.transform = body.transform.interpolate_with(target_transform, delta * rotation_speed)

func is_moving_opposite(input: Vector3, velocity: Vector3) -> bool:
	if input.length() < 0.1 or velocity.length() < 0.1:
		return false

	var input_dir_normalized = input.normalized()
	var velocity_dir_normalized = Vector3(velocity.x, 0, velocity.z).normalized()
	var dot_product = velocity_dir_normalized.dot(input_dir_normalized)
	return dot_product < -0.3
