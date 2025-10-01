class_name PlayerViewController
extends Node

@export var mouse_sensitivity := Vector2(0.003, 0.003)
@export var aim_sensitivity := Vector2(0.001, 0.001)

@export var body: Node3D
@export var camera_root: Node3D
@export var camera: Camera3D
@onready var player: CharacterBody3D = get_parent()

@export_category("Camera")
@export var fov := 60
@export var running_fov := 70
@export var fov_change_speed := 50.0

var locked_target: Node3D

func _ready() -> void:
	if is_multiplayer_authority():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and not locked_target:
		var sens = mouse_sensitivity
		player.rotate_y(-event.relative.x * sens.x)
		if body and player.velocity.length() < 0.5:
			body.rotate_y(event.relative.x * sens.x)
		camera_root.rotate_x(-event.relative.y * sens.y)
		camera_root.rotation.x = clamp(camera_root.rotation.x, deg_to_rad(-70), deg_to_rad(70))
	elif event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_VISIBLE

func _process(delta: float) -> void:
	_align_to_locked_target()

func _align_to_locked_target() -> void:
	if not locked_target:
		return

	var target_dir: Vector3 = (locked_target.global_position - player.global_position).normalized()
	var flat_dir := Vector3(target_dir.x, 0.0, target_dir.z)
	if flat_dir.length() > 0.0001:
		flat_dir = flat_dir.normalized()
		var yaw := Vector3.FORWARD.signed_angle_to(flat_dir, Vector3.UP)
		player.rotation.y = yaw
		if body:
			body.rotation.y = yaw

	var horiz_len := Vector2(target_dir.x, target_dir.z).length()
	var pitch := -atan2(target_dir.y, horiz_len) if horiz_len > 0.0001 else 0.0
	camera_root.rotation.x = clamp(pitch, deg_to_rad(-70), deg_to_rad(70))
