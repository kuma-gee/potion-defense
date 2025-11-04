class_name ItemReceiver
extends RayInteractable

signal item_received(item_type: ItemResource.Type)
signal item_rejected(item_type: ItemResource.Type)

@export var snap_to_center: bool = true
@export var snap_offset: Vector3 = Vector3.ZERO
@export var detection_height_threshold: float = 0.5
@export var auto_remove_item: bool = true
@export var accept_held_items: bool = true
@export var accept_dropped_items: bool = true

func _ready() -> void:
	super()
	# interacted.connect(_on_interacted)

# func _on_interacted(actor: Node) -> void:
# 	if not accept_held_items:
# 		return
	
# 	if actor is FPSPlayer:
# 		var player := actor as FPSPlayer
# 		if player.has_item():
# 			var item_type := player.held_item_type as ItemResource.Type
			
# 			if can_accept_item(item_type):
# 				_process_item(player, item_type)

func _process_item(player: FPSPlayer, item_type: ItemResource.Type) -> void:
	var accepted := handle_item_received(item_type)
	
	if accepted:
		player.release_item()
		item_received.emit(item_type)
		print("Received item: %s" % ItemResource.build_name(item_type))
	else:
		item_rejected.emit(item_type)
		print("Rejected item: %s" % ItemResource.build_name(item_type))

# Virtual method - override in derived classes
func can_accept_item(_item_type: ItemResource.Type) -> bool:
	return true

# Virtual method - override in derived classes
# Return true if item was accepted, false if rejected
func handle_item_received(_item_type: ItemResource.Type) -> bool:
	return true
