extends Area3D

func _ready() -> void:
	area_entered.connect(_remove_ingredient)

func _remove_ingredient(area: Area3D):
	if area is PickupableIngredient:
		area.queue_free()
