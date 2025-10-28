class_name LaneReceiver
extends ItemReceiver

signal potion_placed(potion_type: ItemResource.Type)

var lane: Lane

func _ready() -> void:
	super()
	
	# Configure receiver for lane
	snap_to_center = true
	auto_remove_item = false
	accept_held_items = true
	accept_dropped_items = true
	detection_height_threshold = 0.3

func set_lane(l: Lane) -> void:
	lane = l

func can_accept_item(item_type: ItemResource.Type) -> bool:
	# Only accept potions (not empty, not ingredients)
	if not ItemResource.is_potion(item_type):
		return false
	
	# Don't accept if lane already has a potion
	if lane and lane.item != null:
		return false
	
	return true

func handle_item_received(item_type: ItemResource.Type, _pickupable: Pickupable) -> bool:
	if not lane:
		return false
	
	lane.potion = item_type
	potion_placed.emit(item_type)
	print("Placed potion on lane: %s" % ItemResource.build_name(item_type))
	
	return true
