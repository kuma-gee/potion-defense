extends Node3D

@export var chain_count := 3
@export var hit_area: Area3D
@export var damage := 1
@export var status: StatusEffect
@export var anim: AnimationPlayer

var hit_targets := []

func _ready() -> void:
	while chain_count > 0:
		var target = _get_closest_target()
		if not target: break
		target.hit(damage)
		if status:
			target.status_manager.apply_status_effect(status)

		global_position = target.global_transform
		hit_targets.append(target)
		chain_count -= 1
		anim.play("hit")
		await get_tree().create_timer(0.2).timeout

	
func _get_closest_target() -> Node3D:
	var areas = hit_area.get_overlapping_areas()
	var closest_body: Node3D = null
	var closest_distance = INF
	var origin = global_transform.origin

	for area in areas:
		if area is Area3D and not area in hit_targets:
			var body = area.get_overlapping_bodies()[0]
			if body is Node3D:
				var body_pos = body.global_transform.origin
				var distance = origin.distance_to(body_pos)
				if distance < closest_distance:
					closest_distance = distance
				closest_body = body
				
	return closest_body
