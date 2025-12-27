@tool
extends Node3D

@export var rotation_amount := 360
@export var min_scale = 0.9
@export var max_scale = 1.1

func _ready() -> void:
	rotation.y = deg_to_rad(randf_range(0, rotation_amount))

	var scale_amount = randf_range(min_scale, max_scale)
	scale = Vector3.ONE * scale_amount
