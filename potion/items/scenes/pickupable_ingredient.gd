class_name PickupableIngredient
extends RayInteractable

@export var type: ItemResource.Type = ItemResource.Type.RED_HERB

func interact(actor: FPSPlayer):
	actor.pickup_item(ItemResource.get_resource(type))
	queue_free()
