extends Node

#signal game_started()
signal level_started(map: PackedScene)
signal souls_changed()
signal cauldron_used()
signal cauldron_destroyed()
signal picked_up_recipe(recipe: ItemResource)

var players := []
var total_souls := 0
var level := 0

var unlocked_recipes: Array[ItemResource.Type] = []
var unlocked_upgrades: Array[UpgradeResource] = []

func get_player_count() -> int:
	return players.size()

func player_joined(player: String):
	players.append(player)

func start_level(map: PackedScene):
	level_started.emit(map)
	level += 1

func finished_level(souls: int):
	total_souls += souls

func is_tutorial_level() -> bool:
	return level == 0

func collect_soul(amount: int):
	total_souls += amount
	souls_changed.emit()

func pickup_recipe(item: ItemResource):
	var type = item.type
	if not type in unlocked_recipes:
		unlocked_recipes.append(type)
		picked_up_recipe.emit(item)
		print("Unlocked recipes: %s" % item)

func buy_upgrade(up: UpgradeResource):
	if not up in unlocked_upgrades:
		if total_souls >= up.price:
			total_souls -= up.price
			unlocked_upgrades.append(up)
			print("Unlocked upgrades: %s" % up.name)
		else:
			print("Not enough souls to buy upgrade: %s" % up.name)
