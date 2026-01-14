class_name IngredientSpawnArea
extends Area3D

const MAX_SPAWN_ATTEMPTS := 10

@export var min_item_distance := 1.0
@export var resource: ItemResource
@export var max_count: int = 6
@export var spawn_parent: Node3D
@export var spawn_shape: CollisionShape3D

@onready var respawn_timer: RandomTimer = $RespawnTimer

var rng := RandomNumberGenerator.new()
var spawned_items: Array[Node3D] = []

func _ready() -> void:
	rng.randomize()
	respawn_timer.timeout.connect(_on_respawn_timeout)
	await get_tree().create_timer(0.2).timeout
	_fill_to_max()

func _fill_to_max() -> void:
	while spawned_items.size() < max_count:
		if not _spawn_ingredient():
			break

func _spawn_ingredient() -> bool:
	if spawned_items.size() >= max_count or not resource:
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
		return spawn_shape.global_position + Vector3(
			rng.randf_range(-shape.size.x/2, shape.size.x/2),
			0,
			rng.randf_range(-shape.size.z/2, shape.size.z/2)
		)
	return global_position

func _is_position_free(point: Vector3) -> bool:
	if point:
		return true
	
	for item in spawned_items:
		if not is_instance_valid(item):
			continue
		if item.global_position.distance_to(point) < min_item_distance:
			return false

	var world := get_world_3d()
	if world == null:
		return true
	var space_state := world.direct_space_state
	var query = PhysicsRayQueryParameters3D.create(point, point + Vector3.DOWN)
	query.hit_from_inside = true
	var result := space_state.intersect_ray(query)
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
