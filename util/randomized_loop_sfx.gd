class_name RandomizedLoopSfx
extends AudioStreamPlayer

const GROUP = "AudioSFX"

@export var id := ""
@export var max_plays := 4
@export var min_pitch := 0.8
@export var max_pitch := 1.0
@export var one_shot := false

var active := false

func _ready() -> void:
	add_to_group(GROUP)

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
	if id != "":
		var count = _count_same_audio_plays()
		if count >= max_plays:
			return

	pitch_scale = randf_range(min_pitch, max_pitch)
	play()

func _count_same_audio_plays() -> int:
	var count := 0
	for node in get_tree().get_nodes_in_group(GROUP):
		if node is AudioStreamPlayer and node.id == id and node.playing:
			count += 1
	return count
