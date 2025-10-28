class_name TrajectoryAimingSystem
extends Node

signal aiming_started()
signal aiming_cancelled()
signal projectile_fired(force: float)
signal force_changed(force: float)

@export var min_throw_force := 5.0
@export var max_throw_force := 20.0
@export var force_adjust_sensitivity := 0.5
@export var trajectory_points := 30
@export var trajectory_time_step := 0.1
@export var trajectory_line_width := 0.03
@export var hold_time_threshold := 0.3

@export var position_marker: Node3D
@export var impact_indicator: MeshInstance3D
@export var trajectory_node: MeshInstance3D

@onready var gravity_force = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)

var is_aiming := false
var current_throw_force := 10.0
var aim_start_time := 0.0
var projectile_to_exclude: RigidBody3D = null

func _input(event: InputEvent) -> void:
	if not is_aiming:
		return
	
	if event is InputEventMouseMotion:
		var mouse_motion := event as InputEventMouseMotion
		var force_delta := mouse_motion.relative.y * force_adjust_sensitivity
		current_throw_force = clamp(current_throw_force + force_delta, min_throw_force, max_throw_force)
		force_changed.emit(current_throw_force)
		_update_trajectory_preview()
	
	if event.is_action_pressed("interact"):
		fire()
	elif event.is_action_pressed("drop_item"):
		cancel_aim()

func start_aiming(projectile: RigidBody3D = null) -> void:
	is_aiming = true
	aim_start_time = Time.get_ticks_msec() / 1000.0
	current_throw_force = (min_throw_force + max_throw_force) / 2.0
	projectile_to_exclude = projectile
	
	_update_trajectory_preview()
	
	if trajectory_node:
		trajectory_node.visible = true
	if impact_indicator:
		impact_indicator.visible = false
	
	aiming_started.emit()

func cancel_aim() -> void:
	is_aiming = false
	projectile_to_exclude = null
	
	if trajectory_node:
		trajectory_node.visible = false
	if impact_indicator:
		impact_indicator.visible = false
	
	aiming_cancelled.emit()

func fire() -> void:
	if not is_aiming:
		return
	
	var force = current_throw_force
	is_aiming = false
	projectile_to_exclude = null
	
	if trajectory_node:
		trajectory_node.visible = false
	if impact_indicator:
		impact_indicator.visible = false
	
	projectile_fired.emit(force)

func check_fire_on_release() -> bool:
	if not is_aiming:
		return false
	
	var hold_duration := Time.get_ticks_msec() / 1000.0 - aim_start_time
	if hold_duration >= hold_time_threshold:
		fire()
		return true
	
	return false

func get_throw_direction() -> Vector3:
	var parent_node := get_parent()
	var parent_transform: Transform3D = parent_node.global_transform if parent_node else Transform3D.IDENTITY
	var direction: Vector3 = (parent_transform.basis.z).normalized()
	return direction + Vector3.UP / 3

func get_force_percentage() -> float:
	return (current_throw_force - min_throw_force) / (max_throw_force - min_throw_force)

func _update_trajectory_preview() -> void:
	if not trajectory_node or not is_aiming:
		return
	
	trajectory_node.mesh.clear_surfaces()
	
	var parent_node := get_parent()
	var parent_transform: Transform3D = parent_node.global_transform if parent_node else Transform3D.IDENTITY
	var start_pos: Vector3 = position_marker.global_position if position_marker else parent_transform.origin
	var direction := get_throw_direction()
	var velocity := direction.normalized() * current_throw_force
	var gravity_vec = Vector3.DOWN * gravity_force
	
	var parent_3d := get_parent() as Node3D
	if not parent_3d:
		return
	
	var space_state := parent_3d.get_world_3d().direct_space_state
	var collision_point: Vector3
	var collision_normal: Vector3
	var has_collision := false
	var collision_index := trajectory_points
	
	var positions: Array[Vector3] = []
	for i in range(trajectory_points):
		var time := i * trajectory_time_step
		var pos = start_pos + velocity * time + 0.5 * gravity_vec * time * time
		positions.append(pos)
		
		if i > 0 and not has_collision:
			var query := PhysicsRayQueryParameters3D.create(positions[i - 1], pos)
			if projectile_to_exclude:
				query.exclude = [projectile_to_exclude]
			var result := space_state.intersect_ray(query)
			if result:
				collision_point = result.position
				collision_normal = result.normal
				has_collision = true
				collision_index = i
				break
	
	_draw_trajectory_line(positions, collision_index)
	
	if has_collision:
		_update_impact_indicator(collision_point, collision_normal)
	else:
		if impact_indicator:
			impact_indicator.visible = false

func _draw_trajectory_line(positions: Array[Vector3], end_index: int) -> void:
	trajectory_node.mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for i in range(min(end_index, positions.size()) - 1):
		var p1 := positions[i]
		var p2 := positions[i + 1]
		
		var dir := (p2 - p1).normalized()
		var right := dir.cross(Vector3.UP).normalized()
		if right.length() < 0.001:
			right = dir.cross(Vector3.RIGHT).normalized()
		
		var half_width := trajectory_line_width / 2.0
		
		var v1 := trajectory_node.to_local(p1 + right * half_width)
		var v2 := trajectory_node.to_local(p1 - right * half_width)
		var v3 := trajectory_node.to_local(p2 + right * half_width)
		var v4 := trajectory_node.to_local(p2 - right * half_width)
		
		trajectory_node.mesh.surface_add_vertex(v1)
		trajectory_node.mesh.surface_add_vertex(v2)
		trajectory_node.mesh.surface_add_vertex(v3)
		
		trajectory_node.mesh.surface_add_vertex(v2)
		trajectory_node.mesh.surface_add_vertex(v4)
		trajectory_node.mesh.surface_add_vertex(v3)
	
	trajectory_node.mesh.surface_end()

func _update_impact_indicator(point: Vector3, normal: Vector3) -> void:
	if not impact_indicator:
		return
	
	impact_indicator.visible = true
	impact_indicator.global_position = point + normal * 0.01
	
	var forward := normal
	var right := forward.cross(Vector3.UP).normalized()
	if right.length() < 0.001:
		right = forward.cross(Vector3.RIGHT).normalized()
	var up := right.cross(forward).normalized()
	
	impact_indicator.global_transform.basis = Basis(right, up, forward)
