class_name ObstacleManager
extends Node

@export var obstacles: Array[Obstacle] = []
@export var activation_timer: RandomTimer

var started = false
var current_obstacle: Obstacle = null

func _ready() -> void:
	activation_timer.timeout.connect(_on_timer_timeout)
	
func start():
	activation_timer.start_random()
	started = true

func _on_timer_timeout() -> void:
	if obstacles.is_empty() or not started:
		return

	var obstacle = obstacles.pick_random()
	if obstacle and obstacle.is_inside_tree():
		current_obstacle = obstacle
		obstacle.activate()
		await obstacle.finished
		
		if started:
			activation_timer.start_random()

func stop():
	#if current_obstacle:
		#current_obstacle.deactivate()
		#current_obstacle = null

	started = false
	activation_timer.stop()
