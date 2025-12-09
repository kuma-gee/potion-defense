class_name EquipmentsSelect
extends Node3D

@export var scene: PackedScene
@export var offset = 1.0
@export var equipment_root: Node3D
@export var wand_root: Node3D

func show_upgrades(upgrades: Array[UpgradeResource]) -> void:
	for child in equipment_root.get_children():
		child.queue_free()
	for child in wand_root.get_children():
		child.queue_free()
	
	var x_offset_eq = 0.0
	var x_offset_wn = 0.0
	for up in upgrades:
		var select = scene.instantiate() as UpgradeSelect
		select.upgrade = up
		if up is EquipmentResource:
			equipment_root.add_child(select)
			select.position = Vector3(x_offset_eq, 0, 0)
			x_offset_eq += offset
		else:
			wand_root.add_child(select)
			select.position = Vector3(x_offset_wn, 0, 0)
			x_offset_wn += offset
