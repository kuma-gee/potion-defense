class_name SpawnAttack
extends Marker3D

@export var attack_spawn: PackedScene
@export var muzzle_scane: PackedScene

func spawn(res):
	var projectile = _spawn_scene(attack_spawn)
	projectile.resource = res
	
	if muzzle_scane:
		_spawn_scene(muzzle_scane)

func _spawn_scene(scene: PackedScene):
	var node = scene.instantiate()
	node.position = global_position
	get_tree().current_scene.add_child(node)
	return node
