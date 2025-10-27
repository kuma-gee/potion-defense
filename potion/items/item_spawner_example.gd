extends Node3D

## Example script showing how to spawn pickupable items
## This can be used for testing or as a reference

const Pickupable = preload("res://potion/items/pickupable.tscn")

func _ready() -> void:
	# Example: Spawn some items at game start
	spawn_item_at_position(ItemResource.Type.RED_HERB, Vector3(2, 1, 0))
	spawn_item_at_position(ItemResource.Type.BLUE_CRYSTAL, Vector3(-2, 1, 0))
	spawn_item_at_position(ItemResource.Type.POTION_FIRE_BOMB, Vector3(0, 1, 2))

func spawn_item_at_position(item_type: ItemResource.Type, position: Vector3) -> Pickupable:
	var pickupable = Pickupable.instantiate() as Pickupable
	pickupable.item_type = item_type
	pickupable.global_position = position
	pickupable.auto_pickup = true  # Enable auto pickup when player gets close
	
	# Connect to the picked_up signal (optional)
	pickupable.picked_up.connect(_on_item_picked_up)
	
	add_child(pickupable)
	return pickupable

func _on_item_picked_up(item_type: ItemResource.Type, actor: Node3D) -> void:
	print("%s picked up %s" % [actor.name, ItemResource.build_name(item_type)])

# Example: Spawn item when pressing a key (for testing)
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var random_type = randi() % ItemResource.Type.size()
		var random_pos = Vector3(randf_range(-5, 5), 2, randf_range(-5, 5))
		spawn_item_at_position(random_type, random_pos)
		print("Spawned random item at %s" % random_pos)
