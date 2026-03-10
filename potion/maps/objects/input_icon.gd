class_name InputIcon
extends InputKey

@export var texture: TextureRect

var current_player: FPSPlayer:
	set(v):
		current_player = v
		if current_player:
			texture.texture = get_texture(current_player.player_input)

func hover(player: FPSPlayer):
	if current_player != null:
		return
	current_player = player

func unhover(player: FPSPlayer):
	if current_player != player:
		return
	current_player = null
