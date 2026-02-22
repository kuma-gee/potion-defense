class_name EnemyPath
extends Path3D

@export var enemies: Array[EnemyResource]
@export var start_wave := 0

func is_active():
	return is_visible_in_tree()
