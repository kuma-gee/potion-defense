class_name Chest
extends RayInteractable

@export var item := ItemResource.Type.RED_HERB:
	set(v):
		item = v
		if is_inside_tree():
			label.text = ItemResource.build_name(item)

func _ready() -> void:
	super()

	self.item = item
	interacted.connect(func(actor: Node):
		if actor is FPSPlayer:
			_give_item(actor as FPSPlayer)
	)

func _give_item(player: FPSPlayer) -> void:
	if player.has_item():
		print("Player already has an item")
		return
	
	player.pickup_item(item)
	print("Gave item from chest: %s" % ItemResource.build_name(item))
