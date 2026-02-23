extends Node

@export var branching: Branching
@export var wave_manager: WaveManager
@export var ectoplasma_area: IngredientSpawnArea

@onready var obstacle_timer: RandomTimer = $ObstacleTimer
@onready var obstacle_manager: ObstacleManager = $ObstacleManager

func _ready() -> void:
	branching.activate()
	
	wave_manager.wave_completed.connect(func():
		branching.activate()
		obstacle_timer.stop()
		ectoplasma_area.disable()
	)
	wave_manager.wave_started.connect(func():
		obstacle_manager.start()
		ectoplasma_area.enable()
	)
	wave_manager.all_waves_completed.connect(func(): obstacle_manager.stop())
