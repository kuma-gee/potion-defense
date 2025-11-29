class_name PotionGame
extends Node3D

@export var souls_label: Label
@export var recipe_ui: RecipeBookUI

@onready var wave_manager: WaveManager = $WaveManager
@onready var player_root: Node3D = $PlayerRoot
@onready var map_root: Node3D = $MapRoot
@onready var level_select: Map = $LevelSelect
@onready var canvas_layer: CanvasLayer = $CanvasLayer

var map: Map:
	set(v):
		map = v
		canvas_layer.visible = map != null
		if map:
			map_root.add_child(map)
			wave_manager.setup(map)
		else:
			for child in map_root.get_children():
				child.queue_free()

var souls := 0:
	set(v):
		souls = v
		souls_label.text = "Souls: %s" % v

func _ready() -> void:
	map = null
	wave_manager.all_waves_completed.connect(_on_all_waves_completed)
	Events.soul_collected.connect(func(): souls += 1)
	Events.level_started.connect(func(scene: PackedScene):
		level_select.process_mode = Node.PROCESS_MODE_DISABLED
		level_select.position.y = -1000
		_setup_map(scene)
	)

func _on_all_waves_completed() -> void:
	map = null
	level_select.process_mode = Node.PROCESS_MODE_INHERIT
	level_select.position.y = 0

	for player in player_root.get_children():
		player.global_position = level_select.get_spawn_position(player.player_num)

func _unhandled_input(event: InputEvent) -> void:
	if wave_manager.is_wave_active:
		if event.is_action_pressed("pause"):
			recipe_ui.pause()

func _setup_map(scene: PackedScene):
	map = scene.instantiate() as Map

	for player in player_root.get_children():
		player.global_position = map.get_spawn_position(player.player_num)
