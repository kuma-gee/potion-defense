class_name Cauldron
extends RayInteractable

var items = []
var current_hovering_player: FPSPlayer = null
var mixing_player: FPSPlayer = null

@export var mix_item_per_item := 0.5
@export var potion_amount := 4
@export var drop_area: Area3D
@export var detection_height_threshold := 0.5

var required_time := 0.0
var time := 0.0
var mixing := 0:
	set(v):
		mixing = max(v, 0)
		if mixing == 0:
			time = 0.0
			_unfreeze_mixing_player()

func _ready() -> void:
	super()
	
	if drop_area:
		drop_area.body_entered.connect(_on_drop_area_body_entered)
	
	hovered.connect(func(a: FPSPlayer):
		current_hovering_player = a
		_update_label(a)
	)
	unhovered.connect(func(_a: FPSPlayer):
		current_hovering_player = null
	)
	interacted.connect(func(a: FPSPlayer):
		if mixing > 0:
			return

		if a and a.has_item():
			# Handle physical items being held
			if a.held_physical_item:
				var pickupable := a.held_physical_item
				var item_type := pickupable.item_type
				
				if item_type == ItemResource.Type.POTION_EMPTY:
					if not items.is_empty() and _is_only_potions():
						pickupable.set_item_type(items.pop_back())
						_update_label(a)
					return
				elif ItemResource.is_potion(item_type):
					items.append(item_type)
					pickupable.set_item_type(ItemResource.Type.POTION_EMPTY)
				else:
					items.append(item_type)
					a.held_physical_item = null
					pickupable.drop()
					pickupable.queue_free()
				
				_update_label(a)
				print("Cauldron items: %s" % [items])
				return
			
			# Handle abstract items (legacy)
			if a.item == ItemResource.Type.POTION_EMPTY:
				if not items.is_empty() and _is_only_potions():
					a.take_item()
					a.hold_item(items.pop_back())
					_update_label(a)
				return
			elif ItemResource.is_potion(a.item):
				items.append(a.take_item())
				a.hold_item(ItemResource.Type.POTION_EMPTY)
			else:
				items.append(a.take_item())
			
			_update_label(a)
			print("Cauldron items: %s" % [items])
		elif mixing <= 0:
			mixing_player = a
			mixing += 1
			if mixing_player:
				mixing_player.freeze_player()
	)
	released.connect(func(_a: FPSPlayer): 
		mixing -= 1
		if mixing <= 0:
			_unfreeze_mixing_player()
	)

func _is_only_potions():
	for i in items:
		if not ItemResource.is_potion(i):
			return false
	return true

func _on_drop_area_body_entered(body: Node3D) -> void:
	if mixing > 0:
		return
	
	if body is Pickupable:
		var pickupable := body as Pickupable
		
		# Check if item is being dropped from above
		if not _is_dropped_from_above(pickupable):
			return
		
		# Check if item is not currently held
		if pickupable.is_picked_up:
			return
		
		# Add the item to the cauldron
		_add_pickupable_to_cauldron(pickupable)

func _is_dropped_from_above(pickupable: Pickupable) -> bool:
	# Check if the pickupable is above the cauldron
	var relative_y := pickupable.global_position.y - global_position.y
	
	# Must be coming from above the threshold
	if relative_y < detection_height_threshold:
		return false
	
	# Check if it has downward velocity
	if pickupable.linear_velocity.y >= 0:
		return false
	
	return true

func _add_pickupable_to_cauldron(pickupable: Pickupable) -> void:
	var item_type := pickupable.item_type
	
	# Handle potion empty bottles
	if item_type == ItemResource.Type.POTION_EMPTY:
		if not items.is_empty() and _is_only_potions():
			# Fill the bottle with a potion
			var potion_type = items.pop_back()
			pickupable.set_item_type(potion_type)
			# Give it an upward impulse to eject it
			pickupable.linear_velocity = Vector3.UP * 5.0
			
			if current_hovering_player:
				_update_label(current_hovering_player)
			
			print("Filled bottle with: %s (%d left)" % [ItemResource.build_name(potion_type), items.size()])
		return
	
	# Handle potions being put back in
	if ItemResource.is_potion(item_type):
		items.append(item_type)
		# Create empty bottle in its place
		pickupable.set_item_type(ItemResource.Type.POTION_EMPTY)
		# Give it an upward impulse to eject it
		pickupable.linear_velocity = Vector3.UP * 5.0
		
		if current_hovering_player:
			_update_label(current_hovering_player)
		
		print("Added potion to cauldron: %s" % ItemResource.build_name(item_type))
	else:
		# Handle regular ingredients
		items.append(item_type)
		pickupable.queue_free()
		
		if current_hovering_player:
			_update_label(current_hovering_player)
		
		print("Added ingredient to cauldron: %s" % ItemResource.build_name(item_type))

func _unfreeze_mixing_player() -> void:
	if mixing_player:
		mixing_player.unfreeze_player()
		mixing_player = null

func _update_label(player: FPSPlayer) -> void:
	if not label:
		return
	
	label.text = ""
	
	if mixing > 0:
		var remaining_time: float = max(0.0, required_time - time)
		label.text = "Mixing... %.1fs" % remaining_time
		return
	
	if player.has_item():
		if ItemResource.is_empty_potion(player.item):
			if not items.is_empty() and _is_only_potions():
				label.text = "Fill (%d left)" % items.size()
			elif not items.is_empty() and not _is_only_potions():
				label.text = "Invalid Potion"
		else:
			label.text = "Put in"
	elif not items.is_empty():
		if _is_only_potions():
			label.text = "Mix (%d potions)" % items.size()
		else:
			label.text = "Mix"

func _process(delta: float) -> void:
	if mixing > 0:
		print("Mixing: %s" % time)
		time += delta
		required_time = mix_item_per_item * items.size()
		
		if current_hovering_player:
			_update_label(current_hovering_player)
		
		if time >= required_time:
			mixing = 0
			_mix_items()

func _mix_items():
	var new_item = ItemResource.find_recipe(items)
	items.clear()

	if new_item:
		for i in potion_amount:
			items.append(new_item)
		
		if current_hovering_player:
			_update_label(current_hovering_player)
		
		print("Mixed: %s" % [items])
		return
	
	# TODO: explode
