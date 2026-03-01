class_name WaterCurrent
extends StaticBody3D

@export var wave_manager: WaveManager
@export var new_skeleton: EnemyResource
@export var current_spawns: Array[EnemyPath] = []

func get_closest_spawn(pos: Vector3) -> EnemyPath:
	var closest_spawn: EnemyPath = null
	var closest_distance: float = INF

	for spawn in current_spawns:
		var curve = spawn.curve
		var first_point = curve.get_point_position(0)
		var distance = pos.distance_to(first_point)
		if distance < closest_distance:
			closest_distance = distance
			closest_spawn = spawn

	return closest_spawn

func spawn_new_for(pos: Vector3):
	var path = get_closest_spawn(pos)
	wave_manager.spawn_enemy(new_skeleton, path)
