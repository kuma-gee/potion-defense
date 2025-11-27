class_name PickupableIngredient
extends RayInteractable

@export var type: ItemResource.Type = ItemResource.Type.RED_HERB

func interact(actor: FPSPlayer):
	if actor.has_item(): return
	
	actor.pickup_item(ItemResource.get_resource(type))
	queue_free()
