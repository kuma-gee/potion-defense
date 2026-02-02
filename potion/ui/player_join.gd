class_name PlayerJoin
extends Node

signal spawned_player()

@export var player_root: Node3D
@export var player_scene: PackedScene
@export var spawn_distance := 1.0

var logger = KumaLog.new("PlayerJoin")

func setup_player(id: String, pos := player_root.global_position):
	var player = _get_player_with_id(id)
	if not player:
		player = _create_player(id, player_root.get_child_count())
		player_root.add_child(player)

	player.position = player_root.to_local(pos) + _get_spawn_position(player.player_num) * spawn_distance
	player.reset()
	spawned_player.emit()
 
func _get_spawn_position(player_num: int) -> Vector3:
	var expected_player_count = 4
	var dir = Vector3.RIGHT
	var step = TAU / expected_player_count

	var over_player_count = floor(player_num / float(expected_player_count))
	var idx = player_num % expected_player_count

	var angle = step * idx
	angle += over_player_count * PI/2.0

	return dir.rotated(Vector3.UP, angle)

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
