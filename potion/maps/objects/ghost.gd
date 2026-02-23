class_name Ghost
extends CharacterBody3D

@export var drop_item: ItemResource
@export var move_speed: float = 0.2
@export var travel_distance: float = 3.0
@onready var player_detection: Area3D = $PlayerDetection

var destination: Vector3 = Vector3.ZERO
var movement_direction: Vector3 = Vector3.ZERO
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	var angle: float = rng.randf_range(0.0, TAU)
	movement_direction = Vector3(cos(angle), 0.0, sin(angle)).normalized()
	destination = global_position + movement_direction * travel_distance
	player_detection.body_entered.connect(func(_b):
		_spawn_drop_item()
		queue_free()
	)

func _physics_process(delta: float) -> void:
	var to_destination: Vector3 = destination - global_position
	var step_distance: float = move_speed * delta

	if to_destination.length() <= step_distance:
		global_position = destination
		velocity = Vector3.ZERO
		_spawn_drop_item()
		queue_free()
		return

	velocity = to_destination.normalized() * move_speed
	move_and_slide()

func _spawn_drop_item() -> void:
	if drop_item == null or drop_item.scene == null:
		return

	var item_node: Node = drop_item.scene.instantiate()
	get_tree().current_scene.add_child(item_node)

	if item_node is Node3D:
		var node_3d: Node3D = item_node as Node3D
		node_3d.global_position = global_position

	if item_node is PickupableIngredient:
		var ingredient: PickupableIngredient = item_node as PickupableIngredient
		ingredient.res = drop_item
