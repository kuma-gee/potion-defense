extends Node

@export var audio: AudioStream
@export var pitch := 1.0
@export var volume := -10.0

func _ready() -> void:
	AudioManager.play_sfx(audio, volume, pitch)
