class_name WaterCurrent
extends StaticBody3D

@export var current_spawns: Array[Node3D] = []

func get_closest_spawn(pos: Vector3) -> Node3D:
	var closest_spawn: Node3D = null
	var closest_distance: float = INF

	for spawn in current_spawns:
		var distance = pos.distance_to(spawn.global_transform.origin)
		if distance < closest_distance:
			closest_distance = distance
			closest_spawn = spawn

	return closest_spawn
