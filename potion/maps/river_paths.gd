extends Node

@export var river: Obstacle
@export var main_path: Array[EnemyPath]
@export var water_path: Array[EnemyPath]

func _ready() -> void:
	_river_deactivated()
	river.activated.connect(_river_activated)
	river.deactivated.connect(_river_deactivated)
	
func _river_deactivated():
	for p in main_path:
		p.show()
	for p in water_path:
		p.hide()
		
func _river_activated():
	for p in main_path:
		p.hide()
	for p in water_path:
		p.show()
