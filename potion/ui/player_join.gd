class_name PlayerJoin
extends Node

@export var player_root: Node3D
@export var player_scene: PackedScene

var logger = KumaLog.new("PlayerJoin")

func setup_player(id: String, map: Map) -> void:
	var player = _get_player_with_id(id)
	if not player:
		player = _create_player(id, player_root.get_child_count())
		player_root.add_child(player)

	player.position = map.get_spawn_position(player.player_num)
 
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

func _get_player_with_id(input_id: String) -> Node3D:
	for player in player_root.get_children():
		if player.input_id == input_id:
			return player
	return null
