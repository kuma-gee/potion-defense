class_name TrashReceiver
extends RayInteractable

@export var trash_icon: Texture2D

func _ready() -> void:
	super()
	hovered.connect(func(a: FPSPlayer): sprite.texture = trash_icon if a.has_item() else null)
	interacted.connect(func(a: FPSPlayer):
		if a and a.has_item():
			a.release_item()
	)
