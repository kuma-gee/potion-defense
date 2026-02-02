extends Node

signal souls_changed()
signal cauldron_used()
signal cauldron_destroyed()
signal picked_up_recipe(recipe: ItemResource)
signal upgrade_unlocked()
signal player_has_joined(id: String)

const MAPS = [
	"res://potion/maps/res/map_01.tres",
	"res://potion/maps/res/map_02.tres",
	"res://potion/maps/res/map_03.tres",
]

@export var max_players: int = 4

var has_played := false
var players := []
var total_souls := 0:
	set(v):
		total_souls = v
		souls_changed.emit()

var level := 0
var unlocked_map := 0
var unlocked_recipes: Array[ItemResource.Type] = []
var unlocked_upgrades: Array[UpgradeResource] = []
var unlocked_shop_items: Array[UpgradeResource] = []

var logger = KumaLog.new("Events")

func reset_game():
	unlocked_map = 0
	total_souls = 0
	has_played = false
	unlocked_recipes = []
	unlocked_upgrades = []
	unlocked_shop_items = []

func get_player_count() -> int:
	return players.size()

func player_input_received(event: InputEvent):
	var id = PlayerInput.create_id(event)
	if id in players:
		return

	if players.size() >= max_players:
		logger.warn("Max players reached, cannot spawn new player: %s" % id)
		return

	players.append(id)
	player_has_joined.emit(id)

func get_current_map():
	if level < MAPS.size():
		return load(MAPS[level]).scene
	return null

func finished_level(map: Map):
	unlocked_map = max(level, unlocked_map)
	for item in map.upgrades:
		if not item in unlocked_shop_items:
			unlocked_shop_items.append(item)

	logger.info("Finished level %d, total souls: %d" % [level, total_souls])

func next_level():
	SceneManager.change_to_map_select()

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
