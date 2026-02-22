extends Node

@export var river: Obstacle
@export var main_path: EnemyPath
@export var water_path: EnemyPath

func _ready() -> void:
	river.activated.connect(_river_activated)
	river.deactivated.connect(_river_deactivated)
	
func _river_deactivated():
	main_path.show()
	
func _river_activated():
	main_path.hide()
