class_name ObjectSpawner
extends Node3D

@export var scene: PackedScene

func spawn() -> Node3D:
	var node = scene.instantiate()
	node.position = global_position
	get_tree().current_scene.add_child(node)
	return node
