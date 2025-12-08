extends Node

#signal game_started()
signal level_started(map: PackedScene)
signal soul_collected()
signal cauldron_used()
signal buy_upgrade(upgrade: UpgradeResource)
signal picked_up_recipe(recipe: ItemResource)

var players := []
var total_souls := 0
var level := 0

func get_player_count() -> int:
	return players.size()

func player_joined(player: String):
	players.append(player)

func start_level(map: PackedScene):
	level_started.emit(map)
	level += 1

func finished_level(souls: int):
	total_souls += souls
