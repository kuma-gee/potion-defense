class_name ObstacleManager
extends Node

@export var obstacles: Array[Obstacle] = []
@export var activation_timer: RandomTimer

var current_obstacle: Obstacle = null

func _ready() -> void:
	activation_timer.timeout.connect(_on_timer_timeout)
	
func start():
	activation_timer.start_random()

func _on_timer_timeout() -> void:
	if obstacles.is_empty():
		return

	var obstacle = obstacles.pick_random()
	if obstacle and obstacle.is_inside_tree():
		current_obstacle = obstacle
		obstacle.activate()
		await obstacle.finished
		activation_timer.start_random()

func stop():
	if current_obstacle:
		current_obstacle.deactivate()
		current_obstacle = null

	activation_timer.stop()
