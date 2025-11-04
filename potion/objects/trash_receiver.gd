class_name TrashReceiver
extends RayInteractable

func _ready() -> void:
	super()
	hovered.connect(func(a: FPSPlayer): label.text = "Throw away" if a and a.has_item() else "")
	interacted.connect(func(a: FPSPlayer):
		if a and a.has_item():
			var item = a.release_item()
			print("Trashed: %s" % ItemResource.build_name(item))
	)
