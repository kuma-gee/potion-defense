class_name Map
extends Node3D

@export var lanes: Node3D
@export var spawn_points: Array[Node3D]
@export var wave_resource: WaveResource

func get_spawn_position(player_num: int) -> Vector3:
	return spawn_points[player_num % spawn_points.size()].global_position
