class_name ProcessActionCircular
extends ProcessAction

signal circle_finished()

@export var circle: Sprite3D
@export var min_input_strength: float = 0.4
@export var resume_angle_tolerance: float = 0.35

@onready var camera: Camera3D = get_viewport().get_camera_3d()

var travelled_angle: float = 0.0
var current_angle: float = 0.0:
	set(v):
		current_angle = wrapf(v, -PI, PI)
		if circle != null:
			circle.rotation.y = -current_angle + PI/2 + PI/6

func _ready() -> void:
	circle.hide()

func _on_action_pressed() -> void:
	current_angle = 0.0
	travelled_angle = 0.0
	circle.show()

func _on_action_released() -> void:
	circle.hide()

func cancel() -> void:
	super()
	circle.hide()

func update(_delta: float) -> void:
	if player == null:
		return

	var input_direction: Vector3 = Vector3.ZERO
	input_direction = player.get_aim_direction(circle.global_position)

	if input_direction.length() < min_input_strength:
		return

	var angle = atan2(input_direction.z, input_direction.x)
	var delta_angle = wrapf(angle - current_angle, -PI, PI)
	var dir = sign(delta_angle)
	var current_dir = sign(travelled_angle)
	
	if dir != 0 and current_dir != 0 and current_dir != dir:
		travelled_angle = 0.0
	
	if abs(travelled_angle) >= TAU:
		travelled_angle = 0.0
		circle_finished.emit()
	
	travelled_angle += delta_angle
	current_angle = angle
