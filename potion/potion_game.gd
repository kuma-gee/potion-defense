class_name PotionGame
extends Node3D

@export var initial_items: Array[ItemResource] = []
@export var map_root: Node3D
@export var map_scene: PackedScene
@export var player_root: Node3D

@export var wave_manager: WaveManager
@export var wave_setup: WaveSetup
@export var unlocked_item: UnlockedItem
@export var recipe_ui: RecipeBookUI

var map: Map
var unlocked_items := [ItemResource.Type.RED_HERB, ItemResource.Type.CHARCOAL]

func _ready() -> void:
	wave_manager.all_waves_completed.connect(_on_all_waves_completed)
	_setup_map()

func _on_all_waves_completed() -> void:
	print("All waves completed! You win!")

func _unhandled_input(event: InputEvent) -> void:
	if wave_manager.is_wave_active:
		if event.is_action_pressed("pause"):
			recipe_ui.pause()

func _setup_map():
	map = map_scene.instantiate() as Map
	map_root.add_child(map)
	wave_manager.setup(map)
