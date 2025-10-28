class_name TrashReceiver
extends ItemReceiver

signal item_trashed(item_type: ItemResource.Type)

var trash: Trash

func _ready() -> void:
	super()
	
	# Configure receiver for trash
	snap_to_center = true
	snap_offset = Vector3.ZERO
	auto_remove_item = true
	accept_held_items = true
	accept_dropped_items = true
	detection_height_threshold = 0.3

func set_trash(t: Trash) -> void:
	trash = t

func can_accept_item(_item_type: ItemResource.Type) -> bool:
	# Trash accepts everything
	return true

func handle_item_received(item_type: ItemResource.Type, _pickupable: Pickupable) -> bool:
	item_trashed.emit(item_type)
	print("Trashed: %s" % ItemResource.build_name(item_type))
	return true  # Always remove the item
