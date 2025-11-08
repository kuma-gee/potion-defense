class_name CauldronReceiver
extends RayInteractable

@export var mix_item_per_item := 0.5
@export var potion_amount := 4

var items: Array = []
var current_hovering_player: FPSPlayer = null
var mixing_player: FPSPlayer = null
var required_time := 0.0
var time := 0.0
var mixing := false:
	set(v):
		mixing = v
		if not mixing:
			time = 0.0
			_unfreeze_mixing_player()

func _ready() -> void:
	super ()
	hovered.connect(func(a: Node): handle_hovered(a))
	unhovered.connect(func(_a: Node): current_hovering_player = null)
	interacted.connect(func(a: Node): handle_interacted(a))
	released.connect(func(a: Node): handle_released(a))

func handle_hovered(actor: Node) -> void:
	if actor is FPSPlayer:
		current_hovering_player = actor
		_update_label(actor)

func handle_interacted(actor: Node) -> void:
	if mixing: return
	if not (actor is FPSPlayer): return
	
	var player := actor as FPSPlayer
	
	if player.has_item():
		var item = player.release_item()
		items.append(item.type)
	elif not items.is_empty():
		if _is_only_potions():
			player.pickup_item(ItemResource.get_resource(items.pop_back()))
		else:
			mixing_player = player
			mixing = true
			if mixing_player:
				mixing_player.freeze_player()

	_update_label(player)

func handle_released(_actor: Node) -> void:
	if mixing:
		mixing = false

func _process(delta: float) -> void:
	if mixing:
		time += delta
		required_time = mix_item_per_item * items.size()
		
		if current_hovering_player:
			_update_label(current_hovering_player)
		
		if time >= required_time:
			mixing = 0
			_mix_items()

func _is_only_potions() -> bool:
	for i in items:
		if not ItemResource.is_potion(i):
			return false
	return true

func _update_label(player: FPSPlayer) -> void:
	if not label:
		return
	
	label.text = ""
	
	if mixing:
		var remaining_time: float = max(0.0, required_time - time)
		label.text = "Mixing... %.1fs" % remaining_time
		return
	
	if player.has_item():
		#var held_item_type = player.held_item_type
		#if ItemResource.is_empty_potion(held_item_type):
			#if not items.is_empty() and _is_only_potions():
				#label.text = "Fill (%d left)" % items.size()
			#elif not items.is_empty() and not _is_only_potions():
				#label.text = "Invalid Potion"
		#else:
		label.text = "Put in"
	elif not items.is_empty():
		if _is_only_potions():
			if player.has_item():
				label.text = "Put in (%d potions)" % items.size()
			else:
				label.text = "Take (%d potions)" % items.size()
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

func reset(_restore = false):
	items.clear()
	mixing = 0
	time = 0.0
	required_time = 0.0
	_unfreeze_mixing_player()
	if current_hovering_player:
		_update_label(current_hovering_player)
