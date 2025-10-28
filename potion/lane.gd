class_name Lane
extends RayInteractable

signal destroyed()

@export var potion_scene: PackedScene
@export var position_marker: Node3D
@export var spawn_distance := 50
@export var hurt_box: HurtBox

@export_category("Throwing")
@export var min_throw_force := 5.0
@export var max_throw_force := 20.0
@export var force_adjust_sensitivity := 0.5
@export var trajectory_points := 30
@export var trajectory_time_step := 0.1
@export var trajectory_line_width := 0.03
@export var impact_indicator: MeshInstance3D
@export var trajectory_node: MeshInstance3D
@export var hold_time_threshold := 0.3
@export var item_receiver: LaneReceiver

@onready var gravity_force = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)

var potion: Throwable
var is_aiming := false
var current_throw_force := 10.0
var aim_start_time := 0.0
# var item = null:
# 	set(v):
# 		if item == null:
# 			potion = null
		
# 		item = v
# 		if item and not potion:
# 			potion = potion_scene.instantiate()
# 			potion.position = position_marker.global_position
# 			get_tree().current_scene.add_child(potion)

var enemies = []

func _ready() -> void:
	super ()
	
	if item_receiver:
		item_receiver.set_lane(self)
		item_receiver.potion_placed.connect(_on_potion_placed)
	
	hovered.connect(func(a: FPSPlayer):
		label.text = "Put Potion" if _can_place_potion(a) else ""
		if potion != null:
			label.text = "Shoot"
	)
	interacted.connect(func(a: FPSPlayer):
		if potion != null:
			if not is_aiming:
				start_aiming()
		# Potion placement is now handled by LaneReceiver automatically
	)
	released.connect(func(_a: FPSPlayer):
		if is_aiming:
			var hold_duration := Time.get_ticks_msec() / 1000.0 - aim_start_time
			if hold_duration >= hold_time_threshold:
				fire()
			else:
				pass
	)
	hurt_box.died.connect(func():
		for e in enemies:
			if is_instance_valid(e):
				e.queue_free()
		enemies.clear()
		destroyed.emit()
		queue_free()
	)
	
	cancel_aim()

func _input(event: InputEvent) -> void:
	if not is_aiming:
		return
	
	if event is InputEventMouseMotion:
		var mouse_motion := event as InputEventMouseMotion
		var force_delta := mouse_motion.relative.y * force_adjust_sensitivity
		current_throw_force = clamp(current_throw_force + force_delta, min_throw_force, max_throw_force)
		_update_aim_label()
	
	if event.is_action_pressed("interact"):
		fire()
	elif event.is_action_pressed("drop_item"):
		cancel_aim()

func start_aiming() -> void:
	is_aiming = true
	aim_start_time = Time.get_ticks_msec() / 1000.0
	current_throw_force = (min_throw_force + max_throw_force) / 2.0
	_update_aim_label()
	_update_trajectory_preview()
	if trajectory_node:
		trajectory_node.visible = true
	if impact_indicator:
		impact_indicator.visible = false

func cancel_aim() -> void:
	is_aiming = false
	if label:
		label.text = "Shoot"
	if trajectory_node:
		trajectory_node.visible = false
	if impact_indicator:
		impact_indicator.visible = false

func _update_aim_label() -> void:
	if label:
		var force_percent := int((current_throw_force - min_throw_force) / (max_throw_force - min_throw_force) * 100)
		label.text = "Force: %d%% (Release to fire)" % force_percent
	_update_trajectory_preview()

func _can_place_potion(a: FPSPlayer) -> bool:
	return a.has_item() and ItemResource.is_potion(a.item) and potion == null

func _on_potion_placed(potion_type: ItemResource.Type) -> void:
	print("Lane received potion: %s" % ItemResource.build_name(potion_type))

func fire():
	if not potion or not is_aiming:
		return
	
	var direction = (global_transform.basis.z).normalized()
	var throw_dir = direction + Vector3.UP / 3
	potion.apply_central_impulse(throw_dir.normalized() * current_throw_force)
	potion = null

	is_aiming = false
	if trajectory_node:
		trajectory_node.visible = false
	if impact_indicator:
		impact_indicator.visible = false

func _update_trajectory_preview() -> void:
	if not trajectory_node or not is_aiming or not potion:
		return
	
	trajectory_node.mesh.clear_surfaces()
	
	var start_pos := position_marker.global_position
	var direction := (global_transform.basis.z).normalized() + Vector3.UP / 3
	var velocity := direction.normalized() * current_throw_force
	var gravity_vec = Vector3.DOWN * gravity_force
	
	var space_state := get_world_3d().direct_space_state
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
			query.exclude = [potion]
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

func get_spawn_position():
	return global_position + global_transform.basis.z.normalized() * spawn_distance
