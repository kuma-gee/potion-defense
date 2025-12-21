class_name Map
extends Node3D

const GROUP = "map"

@export var spawn_point: Node3D
@export var wave_resource: Array[WaveResource]
@export var upgrades: Array[UpgradeResource]
@export var new_recipe: ItemResource
@export var initial_recipe: ItemResource
@export var paths: Array[Path3D]

@onready var level: Level = get_node_or_null("Level")

func _ready() -> void:
	add_to_group(GROUP)
	if level:
		level.hide()

	await get_tree().create_timer(1.0).timeout
	if initial_recipe and not Events.is_recipe_unlocked(initial_recipe):
		var initial = get_node("InitialRecipeSpawner")
		var recipe = initial.spawn()
		recipe.recipe = initial_recipe

func get_spawn_position(player_num: int) -> Vector3:
	var expected_player_count = 4
	var dir = Vector3.RIGHT
	var step = TAU / expected_player_count

	var over_player_count = floor(player_num / float(expected_player_count))
	var idx = player_num % expected_player_count

	var angle = step * idx
	angle += over_player_count * PI/2.0

	return spawn_point.global_position + dir.rotated(Vector3.UP, angle)

func map_finished():
	var recipe_spawner = get_node_or_null("ObjectSpawner")
	if new_recipe and recipe_spawner and not Events.is_recipe_unlocked(new_recipe):
		var recipe = recipe_spawner.spawn() as Node3D
		recipe.recipe = new_recipe
		recipe.tree_exiting.connect(func(): _show_next_level_area())
	else:
		_show_next_level_area()

func _show_next_level_area():
	if level:
		level.show()
