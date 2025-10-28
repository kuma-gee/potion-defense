class_name ItemReceiver
extends Area3D

signal item_received(item_type: ItemResource.Type, pickupable: Pickupable)
signal item_rejected(item_type: ItemResource.Type, pickupable: Pickupable)

@export var snap_to_center: bool = true
@export var snap_offset: Vector3 = Vector3.ZERO
@export var detection_height_threshold: float = 0.5
@export var auto_remove_item: bool = true
@export var accept_held_items: bool = true
@export var accept_dropped_items: bool = true

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is Pickupable:
		var pickupable := body as Pickupable
		
		# Check if we should accept this item
		if not _should_accept_pickupable(pickupable):
			return
		
		# Check if it's coming from above (for dropped items)
		if accept_dropped_items and not pickupable.is_picked_up:
			if not _is_dropped_from_above(pickupable):
				return
		
		# Process the pickupable
		_process_pickupable(pickupable)

func _should_accept_pickupable(pickupable: Pickupable) -> bool:
	# Check if it's held and we accept held items
	if pickupable.is_picked_up and not accept_held_items:
		return false
	
	# Check if it's dropped and we accept dropped items
	if not pickupable.is_picked_up and not accept_dropped_items:
		return false
	
	# Override this in derived classes to add custom filtering
	return can_accept_item(pickupable.item_type)

func _is_dropped_from_above(pickupable: Pickupable) -> bool:
	# Check if the pickupable is above the receiver
	var relative_y := pickupable.global_position.y - global_position.y
	
	# Must be coming from above the threshold
	if relative_y < detection_height_threshold:
		return false
	
	# Check if it has downward velocity
	if pickupable.linear_velocity.y >= 0:
		return false
	
	return true

func _process_pickupable(pickupable: Pickupable) -> void:
	var item_type := pickupable.item_type
	var was_held := pickupable.is_picked_up
	var holder := pickupable.holder
	
	# Remove from player's hand if held
	if was_held and holder:
		if holder.has_method("release_physical_item"):
			holder.release_physical_item()
		elif holder is FPSPlayer:
			var player := holder as FPSPlayer
			if player.held_physical_item == pickupable:
				player.held_physical_item = null
		
		pickupable.drop()
	
	# Snap to position if enabled
	if snap_to_center:
		pickupable.global_position = global_position + snap_offset
		pickupable.linear_velocity = Vector3.ZERO
		pickupable.angular_velocity = Vector3.ZERO
	
	# Call the virtual method to handle the item
	var accepted := handle_item_received(item_type, pickupable)
	
	if accepted:
		item_received.emit(item_type, pickupable)
		
		# Remove the pickupable if auto-remove is enabled
		if auto_remove_item:
			pickupable.queue_free()
	else:
		item_rejected.emit(item_type, pickupable)

# Virtual method - override in derived classes
func can_accept_item(item_type: ItemResource.Type) -> bool:
	return true

# Virtual method - override in derived classes
# Return true if item was accepted, false if rejected
func handle_item_received(item_type: ItemResource.Type, pickupable: Pickupable) -> bool:
	return true
