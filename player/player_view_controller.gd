class_name PlayerViewController
extends Node

@export var mouse_sensitivity := Vector2(0.003, 0.003)
@export var aim_sensitivity := Vector2(0.001, 0.001)
@export var target_lock_circle: Control

@export var body: Node3D
@export var camera_root: Node3D
@export var camera: Camera3D

@onready var player: CharacterBody3D = get_parent()

var locked_target: Node3D:
	set(v):
		locked_target = v
		target_lock_circle.visible = v != null

func _ready() -> void:
	locked_target = null
	if is_multiplayer_authority():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and not locked_target:
		_rotate_player_camera(event)
	elif event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_VISIBLE
	elif event.is_action_pressed("lock_target"):
		locked_target = _find_closest_enemy_in_center() if locked_target == null else null

func _rotate_player_camera(event: InputEventMouseMotion) -> void:
	var sens = mouse_sensitivity
	player.rotate_y(-event.relative.x * sens.x)
	if body and player.velocity.length() < 0.5:
		body.rotate_y(event.relative.x * sens.x)
	camera_root.rotate_x(-event.relative.y * sens.y)
	camera_root.rotation.x = clamp(camera_root.rotation.x, deg_to_rad(-70), deg_to_rad(70))

func _get_visible_enemies() -> Array[Node3D]:
	var visible_enemies: Array[Node3D] = []
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if not enemy is Node3D:
			continue

		var screen_pos: Vector2 = camera.unproject_position(enemy.global_position)
		if screen_pos.x >= 0 and screen_pos.x <= get_viewport().size.x and screen_pos.y >= 0 and screen_pos.y <= get_viewport().size.y:
			visible_enemies.append(enemy)
	return visible_enemies

func _find_closest_enemy_in_center():
	var visible_enemies = _get_visible_enemies()
	if visible_enemies.is_empty():
		return null

	var center = Vector2(get_viewport().size / 2)
	var closest_enemy = visible_enemies[0]
	var closest_dist = (camera.unproject_position(closest_enemy.global_position) - center).length()
	for enemy in visible_enemies:
		var dist = (camera.unproject_position(enemy.global_position) - center).length()
		if dist < closest_dist:
			closest_enemy = enemy
			closest_dist = dist

	return closest_enemy

func _process(_delta: float) -> void:
	_align_to_locked_target()

	if locked_target and not is_instance_valid(locked_target):
		locked_target = null

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
	var pitch := atan2(target_dir.y, horiz_len) if horiz_len > 0.0001 else 0.0
	camera_root.rotation.x = clamp(pitch, deg_to_rad(-70), deg_to_rad(70))
