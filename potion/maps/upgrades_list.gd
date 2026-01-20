class_name UpgradesList
extends Node3D

@export var scene: PackedScene
@export var offset = 2.0
@export var max_count := 3

var open := false

func show_upgrades(upgrades: Array[UpgradeResource]) -> void:
	if open: return
	open = true

	for child in get_children():
		child.queue_free()
	
	var x_offset = 0.0

	upgrades.shuffle()
	for up in range(min(upgrades.size(), max_count)):
		var select = scene.instantiate()
		select.upgrade = upgrades[up]
		select.position = Vector3(x_offset, 0, 0)
		add_child(select)
		x_offset += offset
