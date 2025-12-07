class_name Storage
extends RayInteractable

@export var auto_fill: ItemResource
@export var max_capacity := 6
@export var items_list: Control

@onready var restore_timer: Timer = $RestoreTimer

var storage := []

func _ready() -> void:
	super()
	if auto_fill:
		max_capacity = auto_fill.max_capacity
		restore_timer.wait_time = auto_fill.restore_time
		while not is_max_capacity():
			storage.append(auto_fill)

	hovered.connect(func(a: FPSPlayer): label.text = "Storage" if _can_store(a) else ("Take" if storage.size() > 0 else ""))
	interacted.connect(func(actor: Node):
		if actor is FPSPlayer:
			_handle_interaction(actor as FPSPlayer)
	)
	restore_timer.timeout.connect(_refill)

func _refill():
	if is_max_capacity(): return
	storage.append(auto_fill)

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
		var tex = TextureRect.new()
		tex.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex.custom_minimum_size = Vector2(32, 32)
		tex.texture = item.texture
		items_list.add_child(tex)

func reset(_restore = false):
	storage = []
	_update_items_list()
