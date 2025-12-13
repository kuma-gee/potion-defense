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
	var best_area = _get_facing_area()
	last_collider = best_area

func _get_facing_area() -> RayInteractable:
	var areas = get_overlapping_areas()
	if areas.is_empty():
		return null
	
	var hand_forward = -global_transform.basis.z
	var best_area: RayInteractable = null
	var best_dot = -1.0
	
	for area in areas:
		if area is RayInteractable:
			var direction_to_area = (area.global_position - global_position).normalized()
			var dot = hand_forward.dot(direction_to_area)
			
			if dot > best_dot:
				best_dot = dot
				best_area = area
	
	return best_area

func interact(actor) -> void:
	var area = _get_facing_area()
	if area:
		area.interact(actor)

func release(actor):
	var area = _get_facing_area()
	if area:
		area.release(actor)

func action(actor) -> void:
	var area = _get_facing_area()
	if area:
		area.action(actor)

func action_released(actor) -> void:
	var area = _get_facing_area()
	if area:
		area.action_released(actor)
