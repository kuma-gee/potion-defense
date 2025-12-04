class_name PickupableIngredient
extends RayInteractable

var res: ItemResource

func interact(actor: FPSPlayer):
	if actor.has_item(): return
	
	actor.pickup_item(res)
	queue_free()
