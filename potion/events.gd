extends Node

signal move_to_shop()
signal souls_changed()
signal cauldron_used()
signal cauldron_destroyed()
signal picked_up_recipe(recipe: ItemResource)
signal upgrade_unlocked()

const MAPS = [
	"res://potion/maps/res/map_01.tres",
	"res://potion/maps/res/map_02.tres",
	"res://potion/maps/res/map_03.tres",
]

var shown_inputs := false
var players := []
var total_souls := 0:
	set(v):
		total_souls = v
		souls_changed.emit()

var level := 0
var unlocked_map := 0
var unlocked_recipes: Array[ItemResource.Type] = []
var unlocked_upgrades: Array[UpgradeResource] = []

func get_player_count() -> int:
	return players.size()

func player_joined(player: String):
	players.append(player)

func next_level():
	level += 1
	move_to_shop.emit()
	
func get_current_map():
	if level < MAPS.size():
		return load(MAPS[level]).scene
	return null

func finished_level(souls: int):
	total_souls += souls
	unlocked_map = level

func is_tutorial_level() -> bool:
	return level == 0

func is_first_level() -> bool:
	return level <= 1

func collect_soul(amount: int):
	total_souls += amount

func is_recipe_unlocked(item: ItemResource) -> bool:
	return item.type in unlocked_recipes

func pickup_recipe(item: ItemResource):
	var type = item.type
	if not type in unlocked_recipes:
		unlocked_recipes.append(type)
		picked_up_recipe.emit(item)
		print("Unlocked recipes: %s" % item)

func has_upgrade(up: UpgradeResource) -> bool:
	return up in unlocked_upgrades

func buy_upgrade(up: UpgradeResource):
	if not up in unlocked_upgrades:
		if total_souls >= up.price:
			total_souls -= up.price
			unlocked_upgrades.append(up)
			upgrade_unlocked.emit()
			print("Unlocked upgrades: %s" % up.name)
			return true
		else:
			print("Not enough souls to buy upgrade: %s" % up.name)

	return false
