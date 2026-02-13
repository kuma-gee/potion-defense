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

var golem_counts: Dictionary[GolemResource, int] = {}
var golem_upgrades: Dictionary[GolemResource, Array] = {}

# Debug variables
var enemy_move_speed_multipler = 1.0

var logger = KumaLog.new("Events")

func reset_game():
	unlocked_map = 0
	total_souls = 0
	has_played = false
	unlocked_recipes = []
	unlocked_upgrades = []
	unlocked_shop_items = []
	golem_counts = {}
	golem_upgrades = {}

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
	unlocked_map = max(level + 1, unlocked_map)
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
	if total_souls < up.price:
		print("Not enough souls to buy upgrade: %s" % up.name)
		return false

	total_souls -= up.price

	if up is GolemResource:
		var golem = up as GolemResource
		if not up in golem_counts:
			golem_counts[golem] = 0
		golem_counts[golem] += 1
		upgrade_unlocked.emit()

		print("Bought golem: %s, total count: %d" % [up.name, golem_counts[golem]])
		return

	unlocked_upgrades.append(up)
	upgrade_unlocked.emit()
	print("Unlocked upgrades: %s" % up.name)

	return true

#region Golem Upgrades

func buy_golem_upgrade(golem: GolemResource, up: GolemUpgradeResource):
	if not has_bought_golem(golem):
		print("Golem not unlocked: %s" % golem.name)
		return false

	if total_souls < up.price:
		print("Not enough souls to buy upgrade: %s" % up.name)
		return false

	var count = get_golem_upgrade_count(golem, up)
	if count >= up.values.size():
		print("Max upgrade level reached for %s: %d" % [up.name, count])
		return false

	total_souls -= up.price
	if not golem in golem_upgrades:
		golem_upgrades[golem] = []
	golem_upgrades[golem].append(up)

	upgrade_unlocked.emit()
	print("Unlocked golem upgrade: %s for golem type %s" % [up.name, golem.name])
	return true

func get_golem_upgrades(golem: GolemResource) -> Array[GolemUpgradeResource]:
	return golem_upgrades.get(golem, [])

func get_golem_count(upgrade: UpgradeResource):
	return golem_counts.get(upgrade, 0)
		
func get_golem_upgrade_count(golem: GolemResource, upgrade: GolemUpgradeResource) -> int:
	if not golem in golem_upgrades:
		return 0
	return golem_upgrades[golem].count(upgrade)

func get_golem_upgrade_value(golem: GolemResource, upgrade_type: GolemUpgradeResource.Type) -> float:
	var mult: float = 1.0
	for upgrade in get_golem_upgrades(golem):
		if upgrade.type == upgrade_type:
			var level = get_golem_upgrade_count(golem, upgrade)
			if level > 0 and level <= upgrade.values.size():
				mult *= upgrade.values[level - 1]
	return mult
	
func get_available_golem_counts() -> Dictionary[GolemResource, int]:
	var used_types = get_tree().get_nodes_in_group(Turret.GROUP).map(func(x): return x.golem_res)
	
	var counts: Dictionary[GolemResource, int] = golem_counts.duplicate()
	for type in used_types:
		if not type is GolemResource: continue
		var golem = type as GolemResource
		
		if golem in counts:
			counts[golem] = max(0, counts[golem] - 1)
	
	return counts

func has_available_golems() -> bool:
	var counts = get_available_golem_counts()
	for golem in counts.keys():
		if counts[golem] > 0:
			return true
	return false

func has_bought_golem(golem: GolemResource) -> bool:
	return golem_counts[golem] > 0

#endregion
