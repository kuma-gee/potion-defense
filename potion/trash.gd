class_name Trash
extends RayInteractable

@export var item_receiver: TrashReceiver

func _ready() -> void:
	super()
	
	if item_receiver:
		item_receiver.set_trash(self)
		item_receiver.item_trashed.connect(_on_item_trashed)
	
	hovered.connect(func(a: FPSPlayer):
		label.text = "Throw away" if a and a.has_item() else ""
	)
	interacted.connect(func(a: FPSPlayer):
		# Items are now handled by TrashReceiver automatically
		# This could be used for other interactions if needed
		pass
	)

func _on_item_trashed(item_type: ItemResource.Type) -> void:
	print("Trash received: %s" % ItemResource.build_name(item_type))
