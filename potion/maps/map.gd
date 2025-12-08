class_name Map
extends Node3D

@export var lanes: Node3D
@export var wave_resource: Array[WaveResource]
@export var cauldrons: Array[Cauldron]
@export var upgrades: Array[UpgradeResource]
@export var new_recipe: ItemResource
@export var initial_recipe: ItemResource

@onready var level: Level = $Level

func _ready() -> void:
	level.hide()

	if initial_recipe:
		var initial = get_node("InitialRecipeSpawner")
		var recipe = initial.spawn()
		recipe.recipe = initial_recipe

func get_spawn_position(player_num: int) -> Vector3:
	var cauldron = cauldrons[0]
	var dir = Vector3.RIGHT
	var angle = TAU / 8.0
	return cauldron.global_position + dir.rotated(Vector3.UP, angle * player_num)

func map_finished():
	level.show()
	
	var recipe_spawner = get_node("ObjectSpawner")
	if new_recipe and recipe_spawner:
		var recipe = recipe_spawner.spawn()
		recipe.recipe = new_recipe
