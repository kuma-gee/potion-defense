class_name CauldronReceiver
extends ItemReceiver

signal potion_filled(potion_type: ItemResource.Type)
signal ingredient_added(item_type: ItemResource.Type)
signal potion_added(potion_type: ItemResource.Type)

@export var mix_item_per_item := 0.5
@export var potion_amount := 4

var items: Array = []
var current_hovering_player: FPSPlayer = null
var mixing_player: FPSPlayer = null
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
	hovered.connect(func(a: Node): handle_hovered(a))
	unhovered.connect(func(_a: Node): current_hovering_player = null)
	interacted.connect(func(a: Node): handle_interacted(a))
	released.connect(func(a: Node): handle_released(a))

func handle_hovered(actor: Node) -> void:
	if actor is FPSPlayer:
		current_hovering_player = actor
		_update_label(actor)

func handle_interacted(actor: Node) -> void:
	if mixing > 0:
		return
	
	if actor is FPSPlayer:
		var player := actor as FPSPlayer
		if not player.has_item() and mixing <= 0:
			mixing_player = player
			mixing += 1
			if mixing_player:
				mixing_player.freeze_player()

func handle_released(_actor: Node) -> void:
	mixing -= 1
	if mixing <= 0:
		_unfreeze_mixing_player()

func _process(delta: float) -> void:
	if mixing > 0:
		time += delta
		required_time = mix_item_per_item * items.size()
		
		if current_hovering_player:
			_update_label(current_hovering_player)
		
		if time >= required_time:
			mixing = 0
			_mix_items()

func can_accept_item(_item_type: ItemResource.Type) -> bool:
	# Don't accept items while mixing
	if mixing > 0:
		return false
	
	return true

func _release_item(holder: FPSPlayer, pickupable: Pickupable):
	if ItemResource.is_potion(pickupable.item_type):
		return
	
	super(holder, pickupable)

func handle_item_received(item_type: ItemResource.Type, pickupable: Pickupable) -> bool:
	# Handle empty potion bottles (filling)
	if item_type == ItemResource.Type.POTION_EMPTY:
		if not items.is_empty() and _is_only_potions():
			var potion_type = items.pop_back()
			pickupable.set_item_type(potion_type)
			#pickupable.linear_velocity = Vector3.UP * 5.0
			
			potion_filled.emit(potion_type)
			_update_label_if_hovering()
			
			print("Filled bottle with: %s (%d left)" % [ItemResource.build_name(potion_type), items.size()])
		return false  # Don't remove the pickupable
	
	# Handle potions being put back into cauldron
	if ItemResource.is_potion(item_type):
		items.append(item_type)
		pickupable.set_item_type(ItemResource.Type.POTION_EMPTY)
		#pickupable.linear_velocity = Vector3.UP * 5.0
		
		potion_added.emit(item_type)
		_update_label_if_hovering()
		
		print("Added potion to cauldron: %s" % ItemResource.build_name(item_type))
		return false  # Don't remove, converted to empty bottle
	
	# Handle regular ingredients
	items.append(item_type)
	
	ingredient_added.emit(item_type)
	_update_label_if_hovering()
	
	print("Added ingredient to cauldron: %s" % ItemResource.build_name(item_type))
	return true  # Remove the pickupable

func _is_only_potions() -> bool:
	for i in items:
		if not ItemResource.is_potion(i):
			return false
	return true

func _update_label_if_hovering() -> void:
	if current_hovering_player:
		_update_label(current_hovering_player)

func _update_label(player: FPSPlayer) -> void:
	if not label:
		return
	
	label.text = ""
	
	if mixing > 0:
		var remaining_time: float = max(0.0, required_time - time)
		label.text = "Mixing... %.1fs" % remaining_time
		return
	
	if player.has_item():
		if player.held_physical_item:
			var held_item_type = player.held_physical_item.item_type
			if ItemResource.is_empty_potion(held_item_type):
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

func _unfreeze_mixing_player() -> void:
	if mixing_player:
		mixing_player.unfreeze_player()
		mixing_player = null

func _mix_items() -> void:
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
