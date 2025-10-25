class_name PlayerAnimation
extends AnimationTree

@export var strong_hit_threshold := 10.0
@onready var player: Player = get_parent()

const HIT_REQUEST = "parameters/Hit/request"
const DODGE_REQUEST = "parameters/Dodge/request"
const MOVE_BLEND = "parameters/Move/Move/Walk/blend_amount"
const HIT_FORCE_BLEND = "parameters/HitForce/blend_amount"

var sprinting := false
var motion: Vector3
var velocity: Vector3

func has_velocity():
	return velocity.length() > 0

func has_motion():
	return motion.length() > 0

func is_turning():
	return player.is_moving_opposite(motion, velocity)

func _physics_process(_d: float) -> void:
	velocity = player.velocity
	motion = player.get_forward_input()
	#sprinting = Input.is_action_pressed("sprint")
	set(MOVE_BLEND, motion.length())

func hit(force: float = 1.0):
	set(HIT_FORCE_BLEND, 1 if force >= strong_hit_threshold else 0)
	set(HIT_REQUEST, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func dodge():
	set(DODGE_REQUEST, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
