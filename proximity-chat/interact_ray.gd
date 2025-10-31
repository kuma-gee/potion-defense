class_name InteractRay
extends RayCast3D

@export var player: Node3D

var last_collider = null:
	set(v):
		if last_collider and last_collider.has_method("unhover"):
			last_collider.unhover(player)
		
		last_collider = v
		
		if last_collider and last_collider.has_method("hover"):
			last_collider.hover(player)

func _process(_delta: float) -> void:
	last_collider = get_collider()

func interact(actor) -> void:
	if last_collider and last_collider.has_method("interact"):
		last_collider.interact(actor)

func release(actor):
	if last_collider and last_collider.has_method("release"):
		last_collider.release(actor)
