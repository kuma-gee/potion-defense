class_name CauldronReceiver
extends RayInteractable

@export var mix_item_per_item := 0.5
@export var potion_amount := 4
@export var item_container: Control
@export var item_scene: PackedScene

@export var success_anim: AnimationPlayer
@export var failure_anim: AnimationPlayer

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
		_add_item(item.type)
	elif not items.is_empty():
		if _is_only_potions():
			var item = items.pop_back()
			_remove_item(item)
			player.pickup_item(ItemResource.get_resource(item))
		else:
			mixing_player = player
			mixing = true
			if mixing_player:
				mixing_player.freeze_player()

	_update_label(player)

func _clear_items():
	for child in item_container.get_children():
		child.queue_free()
	items.clear()

func _remove_item(item: ItemResource.Type):
	var child = _find_item_for(item)
	if not child: return
	
	child.count -= 1
	if child.count == 0:
		child.queue_free()

func _add_item(item: ItemResource.Type):
	var child = _find_item_for(item)
	if not child:
		child = _create_item_for(item)
	
	child.count += 1
	items.append(item)

func _create_item_for(item: ItemResource.Type):
	var new_item = item_scene.instantiate()
	new_item.type = item
	item_container.add_child(new_item)
	return new_item

func _find_item_for(item: ItemResource.Type):
	for child in item_container.get_children():
		if child.type == item:
			return child
	return null

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
	_clear_items()

	if new_item:
		for i in potion_amount:
			_add_item(new_item)
		
		if current_hovering_player:
			_update_label(current_hovering_player)
		
		print("Mixed: %s" % [items])
		success_anim.play("init")
		return
	
	failure_anim.play("hit")

func reset(_restore = false):
	_clear_items()
	mixing = 0
	time = 0.0
	required_time = 0.0
	_unfreeze_mixing_player()
	if current_hovering_player:
		_update_label(current_hovering_player)
