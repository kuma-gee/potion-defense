class_name UpgradesList
extends Node3D

signal upgrade_selected(upgrade: UpgradeResource, node: Node3D)

@export var scene: PackedScene
@export var offset = Vector2(2.0, 0)
@export var max_count := 0
@export var random := false

func show_upgrades(upgrades: Array) -> void:
	for child in get_children():
		child.queue_free()
	
	if random:
		upgrades.shuffle()
	
	var item_count = upgrades.size()
	if max_count > 0:
		item_count = min(upgrades.size(), max_count)
	
	var pos_offset = Vector2.ZERO
	for up in range(item_count):
		var select = scene.instantiate()
		select.upgrade = upgrades[up]
		select.position = Vector3(pos_offset.x, 0, pos_offset.y)
		select.upgrade_selected.connect(func(upgrade): upgrade_selected.emit(upgrade, select))
		add_child(select)
		pos_offset += offset
