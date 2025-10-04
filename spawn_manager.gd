class_name SpawnManager
extends Node

@export var root: Node3D
@export var obstacle_resources: Array[ObstacleResource] = []

@export_category("Spawn Settings")
@export var spawn_radius := 6.5
@export var spawn_timer: Timer
@export var min_spawn_time := 0.3
@export var max_spawn_time := 1.0
@export var max_count := 10

var current_obstacles := []
var spawn_time := 1.0

func _ready() -> void:
	spawn_timer.timeout.connect(_on_spawn_timeout)

func _on_spawn_timeout() -> void:
	if current_obstacles.size() == 0:
		print("No obstacles to spawn")
		return
	
	if root.get_child_count() >= max_count:
		print("Max obstacles already spawned")
		return

	var res = current_obstacles.pick_random() as ObstacleResource
	var spawn_instance = res.scene.instantiate() as Node3D
	spawn_instance.position = Vector3.FORWARD.rotated(Vector3.UP, randf() * TAU) * randf_range(0, spawn_radius)
	root.add_child(spawn_instance)

func start(level: int):
	current_obstacles = obstacle_resources.filter(func(o): return level >= o.from_level and (o.to_level <= level or o.to_level < 0))
	spawn_time = lerp(max_spawn_time, min_spawn_time, clamp(float(level - 1) / 20.0, 0.0, 1.0))
	spawn_timer.start(spawn_time)

func stop():
	spawn_timer.stop()

	for child in root.get_children():
		child.queue_free()
