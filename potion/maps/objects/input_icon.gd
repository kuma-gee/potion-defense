class_name InputIcon
extends InputKey

@export var texture: TextureRect

var active_players: Array[FPSPlayer] = []
var current_player: FPSPlayer:
	set(v):
		current_player = v
		if current_player:
			texture.texture = get_texture(current_player.player_input)

func connect_interactable(interactable: RayInteractable):
	texture.hide()
	interactable.hovered.connect(func(a): 
		hover(a)
		texture.show()
	)
	interactable.unhovered.connect(func(a):
		unhover(a)
		if active_players.is_empty():
			texture.hide()
	)

func hover(player: FPSPlayer):
	if player not in active_players:
		active_players.append(player)
	
	current_player = player

func unhover(player: FPSPlayer):
	if player in active_players:
		active_players.erase(player)
	
	current_player = null
