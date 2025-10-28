class_name IngredientReceiver
extends ItemReceiver

# Example usage of ItemReceiver for collecting ingredients

var collected_items: Array[ItemResource.Type] = []

func _ready() -> void:
	super()
	
	# Configure the receiver
	snap_to_center = true
	snap_offset = Vector3(0, 0.5, 0)
	detection_height_threshold = 0.3
	auto_remove_item = true
	accept_held_items = true
	accept_dropped_items = true
	
	# Connect to signals
	item_received.connect(_on_item_received)
	item_rejected.connect(_on_item_rejected)

func can_accept_item(item_type: ItemResource.Type) -> bool:
	# Only accept ingredients, not potions
	return not ItemResource.is_potion(item_type) and not ItemResource.is_empty_potion(item_type)

func handle_item_received(item_type: ItemResource.Type, pickupable: Pickupable) -> bool:
	# Add to collection
	collected_items.append(item_type)
	print("Collected ingredient: %s (Total: %d)" % [ItemResource.build_name(item_type), collected_items.size()])
	return true

func _on_item_received(item_type: ItemResource.Type, _pickupable: Pickupable) -> void:
	print("Successfully received: %s" % ItemResource.build_name(item_type))

func _on_item_rejected(item_type: ItemResource.Type, _pickupable: Pickupable) -> void:
	print("Rejected item: %s" % ItemResource.build_name(item_type))
