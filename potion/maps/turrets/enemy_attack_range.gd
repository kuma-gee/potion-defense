class_name EnemyAttackRange
extends Area3D

func has_enemies():
	return not get_enemies_in_range().is_empty()

func get_enemies_in_range():
	return get_overlapping_bodies().filter(func(b): return is_instance_valid(b) and not b.is_dead())

func get_target():
	var enemies = get_enemies_in_range()
	if enemies.is_empty(): return null
	return enemies[0]
