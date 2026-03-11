class_name SFXPlayer
extends Node

@export var audio: AudioStream
@export var pitch := 1.0
@export var max_pitch := -1.0
@export var volume := -10.0
@export var play_on_ready := true

func _ready() -> void:
	if play_on_ready:
		play()
	
func play():
	var p = randf_range(pitch, max(max_pitch, pitch))
	AudioManager.play_sfx(audio, volume, p)
