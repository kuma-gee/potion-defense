class_name Storage
extends RayInteractable

@export var max_capacity := 6
@export var items_list: Control

var storage := []

func _ready() -> void:
	hovered.connect(func(a: FPSPlayer): label.text = "Storage" if _can_store(a) else ("Take" if storage.size() > 0 else ""))
	interacted.connect(func(actor: Node):
		if actor is FPSPlayer:
			_handle_interaction(actor as FPSPlayer)
	)

func _can_store(player: FPSPlayer) -> bool:
	return player.has_item() and player.held_item_type.is_potion_item() and storage.size() < max_capacity


func _handle_interaction(player: FPSPlayer) -> void:
	if player.has_item():
		if not _can_store(player):
			print("Storage not possible")
			return

		var item = player.release_item()
		storage.append(item)
		print("Stored item: %s" % item.name)
	elif not storage.is_empty():
		var item = storage.pop_back()
		player.pickup_item(item)
		print("Retrieved item: %s" % item.name)
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
