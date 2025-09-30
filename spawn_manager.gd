class_name SpawnManager
extends Node

@export var spawn_radius := 6.5
@export var spawn_objects: Array[PackedScene]
@export var spawn_timer: Timer
@export var root: Node3D

func _ready() -> void:
	spawn_timer.timeout.connect(_on_spawn_timeout)

func _on_spawn_timeout() -> void:
	if spawn_objects.size() == 0:
		return

	var spawn_scene = spawn_objects[randi() % spawn_objects.size()]
	var spawn_instance = spawn_scene.instantiate() as Node3D
	spawn_instance.position = Vector3.FORWARD.rotated(Vector3.UP, randf() * TAU) * randf_range(0, spawn_radius)
	root.add_child(spawn_instance)

func start():
	spawn_timer.start()

func stop():
	spawn_timer.stop()

	for child in root.get_children():
		child.queue_free()
