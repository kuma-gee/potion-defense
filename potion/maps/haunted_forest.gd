extends Node

@export var branching: Branching
@export var wave_manager: WaveManager

@onready var obstacle_timer: RandomTimer = $ObstacleTimer

func _ready() -> void:
	branching.activate()
	
	wave_manager.wave_completed.connect(func():
		branching.activate()
	)
