class_name FollowPlayer
extends Node

@export var follow_speed: float = 3.0
@export var follow_distance: float = 2.0
@export var acceleration: float = 8.0
@export var max_distance: float = 10.0
@export var stop_distance: float = 1.0

@onready var character_body: CharacterBody3D = get_parent()

var player: Player
var current_velocity: Vector3

func _ready():
	_find_player()

func _physics_process(delta):
	if not character_body or not player:
		return
	
	var distance_to_player = character_body.global_position.distance_to(player.global_position)
	
	# Only follow if player is within max distance and farther than stop distance
	if distance_to_player > max_distance:
		# Too far, stop following
		current_velocity = current_velocity.lerp(Vector3.ZERO, delta * acceleration)
	elif distance_to_player > stop_distance:
		# Follow player
		var direction_to_player = (player.global_position - character_body.global_position).normalized()
		var target_velocity = direction_to_player * follow_speed
		
		# Adjust speed based on distance - slower when closer to follow_distance
		var distance_factor = clamp((distance_to_player - stop_distance) / follow_distance, 0.1, 1.0)
		target_velocity *= distance_factor
		
		current_velocity = current_velocity.lerp(target_velocity, delta * acceleration)
	else:
		# Too close, stop
		current_velocity = current_velocity.lerp(Vector3.ZERO, delta * acceleration * 2.0)
	
	# Apply movement
	character_body.velocity = current_velocity
	character_body.move_and_slide()

func _find_player():
	player = get_tree().get_first_node_in_group("player") as Player
