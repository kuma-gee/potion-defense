class_name TrashReceiver
extends ItemReceiver

signal item_trashed(item_type: ItemResource.Type)

func _ready() -> void:
	super()
	hovered.connect(func(a: FPSPlayer): label.text = "Throw away" if a and a.has_item() else "")

func handle_item_received(item_type: ItemResource.Type, _pickupable: Pickupable) -> bool:
	item_trashed.emit(item_type)
	print("Trashed: %s" % ItemResource.build_name(item_type))
	return true
