class_name Map
extends Node3D

const GROUP = "map"

@export var spawn_point: Node3D
@export var wave_resources: Array[WaveResource] = []
@export var upgrades: Array[UpgradeResource]
@export var new_recipe: ItemResource
@export var initial_recipe: ItemResource
@export var paths: Array[Path3D]
@export var entrance_scene: PackedScene

@export var proton_scatter: Array[ProtonScatter]
@onready var level: Level = get_node_or_null("Level")

func _ready() -> void:
	add_to_group(GROUP)
	if level:
		level.hide()

	await get_tree().create_timer(0.5).timeout
	if initial_recipe and not Events.is_recipe_unlocked(initial_recipe):
		var initial = get_node("InitialRecipeSpawner")
		var recipe = initial.spawn()
		recipe.recipe = initial_recipe
	
	for p in proton_scatter:
		p.rebuild()

func map_finished():
	#var recipe_spawner = get_node_or_null("ObjectSpawner")
	# if new_recipe and recipe_spawner and not Events.is_recipe_unlocked(new_recipe):
	# 	var recipe = recipe_spawner.spawn() as Node3D
	# 	recipe.recipe = new_recipe
	# 	recipe.tree_exiting.connect(func(): _show_next_level_area())
	# else:
	Events.finished_level(self)
	_show_next_level_area()

func _show_next_level_area():
	if level:
		level.show()
