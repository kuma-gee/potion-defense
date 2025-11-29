extends Node

signal game_started()
signal level_started(map: PackedScene)
signal soul_collected()

var players := []

func get_player_count() -> int:
	return players.size()

func player_joined(player: String):
	players.append(player)

func start_level(map: PackedScene):
	level_started.emit(map)
