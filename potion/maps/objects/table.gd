extends Node3D

const POTION_MODEL = preload("uid://cdma1u0ll1cvr")

@onready var ray_interactable: Area3D = $RayInteractable
@onready var item_position: Marker3D = $ItemPosition

func _ready() -> void:
	ray_interactable.placed.connect(_on_placed)
	ray_interactable.removed.connect(func():
		for c in item_position.get_children():
			c.queue_free()
	)

func _on_placed(item: ItemResource):
	var scene = item.scene
	if scene == null and item.is_potion_item():
		scene = POTION_MODEL
	
	var node = scene.instantiate()
	item_position.add_child(node)
	
	if node is Area3D:
		node.monitorable = false
		node.monitoring = false
	
	if scene == POTION_MODEL:
		node.type = item.type
