class_name TeleportAbility
extends WandAbility

@export var teleport_distance: float = 5.0

func _on_activate() -> void:
	teleport_distance = wand.effect_value
	_perform_teleport()
	deactivate()

func _perform_teleport() -> void:
	var teleport_direction: Vector3
	
	if player.camera.current:
		teleport_direction = -player.body.global_transform.basis.z
	else:
		var input_dir = player.get_input_direction()
		if input_dir.length() > 0.1:
			teleport_direction = input_dir.normalized()
		else:
			teleport_direction = -player.body.global_transform.basis.z
	
	var target_position = player.global_position + teleport_direction * teleport_distance
	
	var space_state = player.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		player.global_position + Vector3.UP,
		target_position + Vector3.UP
	)
	query.exclude = [player]
	
	var result = space_state.intersect_ray(query)
	
	if result:
		var safe_distance = player.global_position.distance_to(result.position) - 0.5
		target_position = player.global_position + teleport_direction * max(safe_distance, 0.0)
	
	var ground_check = PhysicsRayQueryParameters3D.create(
		target_position + Vector3.UP * 2.0,
		target_position - Vector3.UP * 5.0
	)
	ground_check.exclude = [player]
	
	var ground_result = space_state.intersect_ray(ground_check)
	if ground_result:
		target_position.y = ground_result.position.y
	
	player.global_position = target_position
	player.dash_vfx.emitting = true
	
	print("Teleported %.1f units forward" % teleport_distance)
