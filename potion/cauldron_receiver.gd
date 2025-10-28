class_name CauldronReceiver
extends ItemReceiver

signal potion_filled(potion_type: ItemResource.Type)
signal ingredient_added(item_type: ItemResource.Type)
signal potion_added(potion_type: ItemResource.Type)

var cauldron: Cauldron

func _ready() -> void:
	super()
	
	# Configure receiver for cauldron
	snap_to_center = false
	auto_remove_item = false
	accept_held_items = true
	accept_dropped_items = true
	detection_height_threshold = 0.5

func set_cauldron(c: Cauldron) -> void:
	cauldron = c

func can_accept_item(item_type: ItemResource.Type) -> bool:
	# Don't accept items while mixing
	if cauldron and cauldron.mixing > 0:
		return false
	
	return true

func handle_item_received(item_type: ItemResource.Type, pickupable: Pickupable) -> bool:
	if not cauldron:
		return false
	
	# Handle empty potion bottles (filling)
	if item_type == ItemResource.Type.POTION_EMPTY:
		if not cauldron.items.is_empty() and cauldron._is_only_potions():
			var potion_type = cauldron.items.pop_back()
			pickupable.set_item_type(potion_type)
			pickupable.linear_velocity = Vector3.UP * 5.0
			
			potion_filled.emit(potion_type)
			cauldron._update_label_if_hovering()
			
			print("Filled bottle with: %s (%d left)" % [ItemResource.build_name(potion_type), cauldron.items.size()])
		return false  # Don't remove the pickupable
	
	# Handle potions being put back into cauldron
	if ItemResource.is_potion(item_type):
		cauldron.items.append(item_type)
		pickupable.set_item_type(ItemResource.Type.POTION_EMPTY)
		pickupable.linear_velocity = Vector3.UP * 5.0
		
		potion_added.emit(item_type)
		cauldron._update_label_if_hovering()
		
		print("Added potion to cauldron: %s" % ItemResource.build_name(item_type))
		return false  # Don't remove, converted to empty bottle
	
	# Handle regular ingredients
	cauldron.items.append(item_type)
	
	ingredient_added.emit(item_type)
	cauldron._update_label_if_hovering()
	
	print("Added ingredient to cauldron: %s" % ItemResource.build_name(item_type))
	return true  # Remove the pickupable
