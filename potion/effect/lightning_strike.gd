extends Node3D

@export var chain_count := 3
@export var hit_area: HitBox
@export var status: StatusEffect
@export var hit_vfx_scene: PackedScene

var hit_targets := []

func _ready() -> void:
	await hit_area.area_entered
	while chain_count > 0:
		var target = _get_closest_target()
		if not target: break
		target.hit(hit_area.damage)
		if status:
			target.status_manager.apply_effect(status)
		
		var vfx = hit_vfx_scene.instantiate()
		vfx.position = target.global_position
		get_tree().current_scene.add_child(vfx)

		hit_area.global_position = target.global_position
		hit_targets.append(target)
		chain_count -= 1
		await get_tree().create_timer(0.2).timeout

	await get_tree().create_timer(1.0).timeout
	queue_free()
	
func _get_closest_target() -> Node3D:
	var areas = hit_area.get_overlapping_areas()
	var closest_body: Node3D = null
	var closest_distance = INF
	var origin = global_transform.origin

	for area in areas:
		if area is Area3D and not area in hit_targets:
			var body_pos = area.global_transform.origin
			var distance = origin.distance_to(body_pos)
			if distance < closest_distance:
				closest_distance = distance
			closest_body = area
				
	return closest_body
