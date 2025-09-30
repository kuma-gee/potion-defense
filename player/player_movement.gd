class_name PlayerMovement
extends Node

@export var SPEED = 5.0
@export var SPRINT_SPEED = 8.0
@export var JUMP_VELOCITY = 4.
@export var turn_speed := 20.0

@export_category("Roll")
@export var roll_speed := 30
@export var roll_deaccel := 50
@export var roll_time := 1.0

@onready var player: CharacterBody3D = get_parent()

var rolling := false

func roll():
	var forward = _forward(get_input_dir())
	player.velocity = forward * roll_speed
	#animation_tree.roll()
	rolling = true
	get_tree().create_timer(roll_time).timeout.connect(func(): rolling = false)

func get_input_dir():
	return Input.get_vector("move_right", "move_left", "move_down", "move_up")

func _unhandled_input(_event: InputEvent) -> void:
	if player.is_dead():
		return
	
	# if event.is_action_pressed("roll") and player.is_grounded():
	# 	roll()

func _physics_process(delta):
	if player.is_dead():
		return
	
	if rolling:
		player.velocity.x = move_toward(player.velocity.x, 0, roll_deaccel * delta)
		player.velocity.z = move_toward(player.velocity.z, 0, roll_deaccel * delta)
		player.move_and_slide()
		return
	
	#if Input.is_action_just_pressed("jump") and player.is_grounded():
		#player.velocity.y = JUMP_VELOCITY

	var direction = _forward(get_input_dir())
	var _speed = SPEED
	if Input.is_action_pressed("sprint"):
		_speed = SPRINT_SPEED
	
	if player.is_grounded():
		if direction:
			player.velocity.x = direction.x * _speed
			player.velocity.z = direction.z * _speed
		else:
			player.velocity.x = lerp(player.velocity.x, direction.x * _speed, delta * 15.0)
			player.velocity.z = lerp(player.velocity.z, direction.z * _speed, delta * 15.0)
	else:
		player.velocity.x = lerp(player.velocity.x, direction.x * _speed, delta * 3.0)
		player.velocity.z = lerp(player.velocity.z, direction.z * _speed, delta * 3.0)

	player.apply_gravity(delta)
	player.move_and_slide()

func _forward(dir: Vector2):
	return (player.transform.basis.rotated(Vector3.UP, PI) * Vector3(dir.x, 0, dir.y)).normalized()
