class_name Drifting
extends Node

@export var drift_speed: float = 1.5
@export var direction_change_time: float = 2.5
@export var smoothness: float = 3.0
@export var vertical_range: float = 0.5
@export var vertical_speed: float = 1.2

@onready var character_body: CharacterBody3D = get_parent()

var current_direction: Vector3
var target_direction: Vector3
var direction_timer: float = 0.0
var vertical_offset: float = 0.0
var initial_y_position: float

func _ready():
	if character_body:
		initial_y_position = character_body.global_position.y
	_generate_new_direction()

func _physics_process(delta):
	if not character_body:
		return
	
	direction_timer += delta
	
	# Change direction periodically
	if direction_timer >= direction_change_time:
		_generate_new_direction()
		direction_timer = 0.0
	
	# Smooth interpolation to target direction
	current_direction = current_direction.lerp(target_direction, delta * smoothness)
	
	# Add vertical floating motion
	vertical_offset += delta * vertical_speed
	var vertical_movement = sin(vertical_offset) * vertical_range
	
	# Apply movement
	character_body.velocity = current_direction * drift_speed
	character_body.velocity.y = vertical_movement
	
	character_body.move_and_slide()

func _generate_new_direction():
	# Generate random horizontal direction
	var angle = randf() * TAU
	target_direction = Vector3(cos(angle), 0, sin(angle)).normalized()
