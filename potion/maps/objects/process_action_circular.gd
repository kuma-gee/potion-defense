class_name ProcessActionCircular
extends "res://potion/maps/objects/process_action.gd"

@export var required_rotations: float = 1.0
@export var timeout: float = 5.0
@export var min_input_strength: float = 0.4

var elapsed: float = 0.0
var accumulated_angle: float = 0.0
var last_angle: float = 0.0
var has_last_angle: bool = false

func _reset_state() -> void:
	elapsed = 0.0
	accumulated_angle = 0.0
	has_last_angle = false

func _on_update(delta: float) -> void:
	elapsed += delta
	if timeout > 0.0 and elapsed >= timeout:
		fail()
		return

	if player == null:
		return

	var input_direction: Vector3 = player.get_input_direction()
	if input_direction.length() < min_input_strength:
		has_last_angle = false
		return

	var angle = atan2(input_direction.z, input_direction.x)
	if not has_last_angle:
		last_angle = angle
		has_last_angle = true
		return

	var delta_angle = wrapf(angle - last_angle, -PI, PI)
	accumulated_angle += delta_angle
	last_angle = angle

	var goal = TAU * max(required_rotations, 0.01)
	var progress = clamp(absf(accumulated_angle) / goal, 0.0, 1.0)
	if progress >= 1.0:
		complete()
