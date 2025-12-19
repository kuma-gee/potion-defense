class_name PlayerJoin
extends Node

@export var player_root: Node3D
@export var player_scene: PackedScene
@export var max_players: int = 4

var logger = KumaLog.new("PlayerJoin")

func spawn_player(event: InputEvent, map: Map) -> void:
	var id = PlayerInput.create_id(event)

	if player_root.get_child_count() >= max_players:
		logger.warn("Max players reached, cannot spawn new player: %s" % id)
		return

	if _has_player_with_id(id):
		return

	var player = _create_player(id, player_root.get_child_count())
	player.position = map.get_spawn_position(player.player_num)
	player_root.add_child(player)
	Events.player_joined(id)
 
func _create_player(input_id: String, player_num: int):
	var player = player_scene.instantiate() as FPSPlayer
	player.input_id = input_id
	player.player_num = player_num
	player.died.connect(func():
		var new_player = _create_player(input_id, player_num)
		new_player.position = player.global_position
		player.queue_free()
		player_root.add_child(new_player)
	)
	return player

func _has_player_with_id(input_id: String) -> bool:
	for player in player_root.get_children():
		if player.input_id == input_id:
			return true
	return false
