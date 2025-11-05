extends Area3D

@export var player: Node3D

var last_collider = null:
	set(v):
		if last_collider and last_collider.has_method("unhover"):
			last_collider.unhover(player)
		
		last_collider = v
		
		if last_collider and last_collider.has_method("hover"):
			last_collider.hover(player)

func _process(_delta: float) -> void:
	for a in get_overlapping_areas():
		if a is RayInteractable:
			last_collider = a
			break

func interact(actor) -> void:
	for a in get_overlapping_areas():
		if a is RayInteractable:
			a.interact(actor)

func release(actor):
	for a in get_overlapping_areas():
		if a is RayInteractable:
			a.release(actor)
