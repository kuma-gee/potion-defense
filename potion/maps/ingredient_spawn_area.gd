class_name IngredientSpawnArea
extends Area3D

const MAX_SPAWN_ATTEMPTS := 10

@export var min_item_distance := 0.5
@export var resource: ItemResource
@export var respawn_timer: RandomTimer
@export var max_count: int = 6
@export var spawn_parent: Node3D
@export var spawn_shape: CollisionShape3D

var rng := RandomNumberGenerator.new()
var spawned_items: Array[Node3D] = []

func _ready() -> void:
	rng.randomize()
	respawn_timer.timeout.connect(_on_respawn_timeout)
	await get_tree().create_timer(0.1).timeout
	_fill_to_max()

func _fill_to_max() -> void:
	while spawned_items.size() < max_count:
		if not _spawn_ingredient():
			break

func _spawn_ingredient() -> bool:
	if spawned_items.size() >= max_count:
		return false

	var scene: PackedScene = resource.scene
	if scene == null:
		return false

	var parent_node := spawn_parent if spawn_parent else self
	if parent_node == null:
		return false

	var spawn_point = _find_free_spawn_point()
	if spawn_point == null:
		return false

	var ingredient := scene.instantiate() as PickupableIngredient
	if ingredient == null:
		return false

	ingredient.res = resource
	parent_node.add_child(ingredient)
	ingredient.global_position = spawn_point
	spawned_items.append(ingredient)
	ingredient.tree_exited.connect(func():
		spawned_items.erase(ingredient)
		_schedule_respawn()
	)
	return true

func _find_free_spawn_point() -> Variant:
	for i in range(MAX_SPAWN_ATTEMPTS):
		var candidate = _get_random_point_in_area()
		if _is_position_free(candidate):
			return candidate
	return null

func _get_random_point_in_area() -> Vector3:
	if spawn_shape and spawn_shape.shape:
		var shape = spawn_shape.shape as BoxShape3D
		var local_point = Vector3(
			rng.randf_range(spawn_shape.position.x - shape.size.x/2, spawn_shape.position.x + shape.size.x/2),
			spawn_shape.position.y,
			rng.randf_range(spawn_shape.position.z - shape.size.z/2, spawn_shape.position.z + shape.size.z/2)
		)
		return spawn_shape.to_global(local_point)
	return global_position

func _is_position_free(point: Vector3) -> bool:
	for item in spawned_items:
		if not is_instance_valid(item):
			continue
		if item.global_position.distance_to(point) < min_item_distance:
			return false

	var world := get_world_3d()
	if world == null:
		return true
	var space_state := world.direct_space_state
	var params := PhysicsPointQueryParameters3D.new()
	params.position = point
	params.collide_with_areas = true
	params.collide_with_bodies = true
	params.collision_mask = collision_mask if collision_mask != 0 else 0xFFFFFFFF
	params.exclude = [get_rid()]
	var result := space_state.intersect_point(params, 1)
	return result.is_empty()

func _on_respawn_timeout() -> void:
	if not _spawn_ingredient():
		_schedule_respawn()

func _schedule_respawn() -> void:
	if spawned_items.size() >= max_count:
		return

	if not respawn_timer.is_stopped() or not is_inside_tree():
		return
	
	respawn_timer.start_random()
