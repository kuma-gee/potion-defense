class_name Chest
extends RayInteractable

@export var item := ItemResource.Type.RED_HERB

func _ready() -> void:
	super()
	label.text = ItemResource.build_name(item)
	interacted.connect(func(a: FPSPlayer):
		if a:
			a.hold_item(item)
	)
