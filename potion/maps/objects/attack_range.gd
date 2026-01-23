class_name AttackRange
extends Area3D

func has_enemies_in_range() -> bool:
	var enemies = get_overlapping_bodies()
	for enemy in enemies:
		if is_instance_valid(enemy):
			return true
	return false

func find_nearest_enemy() -> Node3D:
	var enemies = get_overlapping_bodies()
	var nearest: Node3D = null
	var nearest_distance := -1.0
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		
		var distance = global_position.distance_to(enemy.global_position)
		if nearest_distance < 0 or distance < nearest_distance:
			nearest = enemy
			nearest_distance = distance
	
	return nearest
