class_name Cauldron
extends RayInteractable

var items = []
var current_hovering_player: FPSPlayer = null
var mixing_player: FPSPlayer = null

@export var mix_item_per_item := 0.5
@export var potion_amount := 4
@export var item_receiver: CauldronReceiver

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
	
	if item_receiver:
		item_receiver.set_cauldron(self)
		item_receiver.item_received.connect(_on_item_received)
	
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
			# Items are now handled by CauldronReceiver automatically
			# This is just for the mixing interaction
			pass
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

func _on_item_received(item_type: ItemResource.Type, _pickupable: Pickupable) -> void:
	print("Cauldron items: %s" % [items])

func _update_label_if_hovering() -> void:
	if current_hovering_player:
		_update_label(current_hovering_player)

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
