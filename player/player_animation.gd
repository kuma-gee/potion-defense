extends AnimationTree

@export var player_move: PlayerMovement
@onready var player: CharacterBody3D = get_parent()

var sprinting := false
var motion: Vector3
var velocity: Vector3

func has_velocity():
	return velocity.length() > 0

func has_motion():
	return motion.length() > 0

func is_turning():
	return player_move.is_moving_opposite(motion, velocity)

func _physics_process(_d: float) -> void:
	velocity = player.velocity
	motion = player_move.get_forward_input()
	sprinting = Input.is_action_pressed("sprint")
