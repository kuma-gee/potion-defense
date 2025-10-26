class_name Trash
extends RayInteractable

func _ready() -> void:
	super()
	hovered.connect(func(a: FPSPlayer):
		label.text = "Throw away" if a and a.has_item() else ""
	)
	interacted.connect(func(a: FPSPlayer):
		if a and a.has_item():
			a.take_item()
	)
