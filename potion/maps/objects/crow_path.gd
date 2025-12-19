extends Path3D

signal finished()

@export_category("Crow")
@export var crow_move_speed := 0.5
@export var crow_path: PathFollow3D
@onready var crow_sound: AudioStreamPlayer = $CrowSound

func _ready() -> void:
	crow_sound.play()

func _process(delta: float) -> void:
	if crow_path.progress_ratio < 1.0 and crow_path.visible:
		var value = crow_move_speed * delta
		if crow_path.progress_ratio + value > 1.0:
			crow_path.progress_ratio = 1.0
			crow_path.hide()
			finished.emit()
		else:
			crow_path.progress_ratio += value
	
