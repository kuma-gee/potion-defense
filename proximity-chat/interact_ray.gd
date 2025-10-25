class_name InteractRay
extends RayCast3D

@export var player: Node3D

var last_collider: RayInteractable = null:
	set(v):
		if last_collider:
			last_collider.unhover(player)
		
		last_collider = v
		
		if last_collider:
			last_collider.hover(player)

func _process(_delta: float) -> void:
	last_collider = get_collider()

func interact(actor) -> void:
	if last_collider:
		last_collider.interact(actor)

func release(actor):
	if last_collider:
		last_collider.release(actor)
