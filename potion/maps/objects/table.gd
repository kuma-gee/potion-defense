class_name Table
extends Node3D

const GROUP = "table"
const POTION_MODEL = preload("uid://cdma1u0ll1cvr")

signal floating_finished(success: bool)

@onready var ray_interactable: RayInteractable = $RayInteractable
@onready var item_position: Marker3D = $ItemPosition
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	add_to_group(GROUP)
	ray_interactable.placed.connect(_on_placed)
	ray_interactable.removed.connect(func():
		for c in item_position.get_children():
			c.queue_free()
		
		if animation_player.is_playing():
			animation_player.play("RESET")
			floating_finished.emit(false)
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

func start_floating():
	if not has_item():
		return
	
	animation_player.play("float")

func finish_floating():
	floating_finished.emit(true)

func has_item():
	return ray_interactable.item != null

func remove_item():
	ray_interactable.item = null
