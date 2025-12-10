class_name Storage
extends RayInteractable

@export var auto_fill: ItemResource
@export var max_capacity := 5
@export var items_list: Control
@export var item_scene: PackedScene
@export var scatter_amount := [2, 5, 15, 20]

@onready var restore_timer: Timer = $RestoreTimer
@onready var scatter_item: Node3D = $ProtonScatter/ScatterItem
@onready var proton_scatter: Node3D = $ProtonScatter

var storage := []

func _ready() -> void:
	super()
	if auto_fill:
		max_capacity = auto_fill.max_capacity
		restore_timer.wait_time = auto_fill.restore_time
		while not is_max_capacity():
			storage.append(auto_fill)
		_update_items_list()

	hovered.connect(func(a: FPSPlayer): label.text = "Storage" if _can_store(a) else ("Take" if storage.size() > 0 else ""))
	interacted.connect(func(actor: Node):
		if actor is FPSPlayer:
			_handle_interaction(actor as FPSPlayer)
	)
	restore_timer.timeout.connect(_refill)

func _refill():
	if is_max_capacity(): return
	storage.append(auto_fill)
	_update_items_list()

func is_max_capacity():
	return storage.size() >= max_capacity

func _can_store(player: FPSPlayer) -> bool:
	return player.has_item() and not is_max_capacity() and _is_type_allowed(player.held_item_type)

func _is_type_allowed(item: ItemResource) -> bool:
	if auto_fill:
		return item.type == auto_fill.type
	return storage.is_empty() or item.type == storage[0].type

func _handle_interaction(player: FPSPlayer) -> void:
	if player.has_item():
		if not _can_store(player):
			print("Storage not possible")
			return

		var item = player.release_item()
		storage.append(item)
		print("Stored item: %s" % item.name)
		if is_max_capacity() and not restore_timer.is_stopped():
			restore_timer.stop()
	elif not storage.is_empty():
		var item = storage.pop_back()
		player.pickup_item(item)
		print("Retrieved item: %s" % item.name)
		if auto_fill and restore_timer.is_stopped():
			restore_timer.start()
	else:
		return

	_update_items_list()

func _update_items_list() -> void:
	for child in items_list.get_children():
		child.queue_free()

	for item in storage:
		var node = item_scene.instantiate()
		node.item = item
		items_list.add_child(node)
	
	if storage.is_empty():
		scatter_item.path = ""
		return
	
	var stack = proton_scatter.modifier_stack.stack
	for s in stack:
		if s is CreateInsideRandom:
			var count = storage.size()
			count -= 1
			var amount = scatter_amount[min(count, scatter_amount.size() - 1)]
			s.amount = amount
			break
	
	var scene = storage[0].scene as PackedScene
	scatter_item.path = scene.resource_path # call everytime to update

func reset(_restore = false):
	storage = []
	_update_items_list()
