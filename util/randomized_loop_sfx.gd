class_name RandomizedLoopSfx
extends AudioStreamPlayer

@export var min_pitch := 0.8
@export var max_pitch := 1.0
@export var one_shot := false

var active := false

func _ready() -> void:
	if one_shot:
		finished.connect(func(): active = false)
	else:
		finished.connect(func():
			if active:
				play_randomized()
			)

func start():
	active = true
	play_randomized()

func end():
	active = false

func play_randomized():
	pitch_scale = randf_range(min_pitch, max_pitch)
	play()
