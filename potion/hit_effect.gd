class_name HitEffect
extends Area3D

signal hit()

@export var scene: PackedScene

func _ready() -> void:
	area_entered.connect(func(_a): on_hit())

func on_hit():
	var node = scene.instantiate()
	node.position = global_position
	get_tree().current_scene.add_child(node)
	hit.emit()
