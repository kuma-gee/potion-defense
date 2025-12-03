class_name PotionGame
extends Node3D

@export var souls_label: Label
@export var recipe_ui: RecipeBookUI
@export var gameover: GameoverScreen

@onready var wave_manager: WaveManager = $WaveManager
@onready var player_root: Node3D = $PlayerRoot
@onready var map_root: Node3D = $MapRoot
@onready var level_select: Map = $LevelSelect
@onready var in_game_canvas: CanvasLayer = $InGameCanvas

var current_level: PackedScene
var map: Map:
	set(v):
		map = v
		in_game_canvas.visible = map != null
		for child in map_root.get_children():
			child.queue_free()
		
		if map:
			map_root.add_child(map)

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
		current_level = scene
		_setup_map()
	)
	
	gameover.restart_level.connect(func(): _setup_map())
	gameover.back_to_select.connect(func(): back_to_level_select())

func _on_all_waves_completed() -> void:
	back_to_level_select()

func back_to_level_select():
	wave_manager.clear()
	map = null
	level_select.process_mode = Node.PROCESS_MODE_INHERIT
	level_select.position.y = 0
	_move_players_to_map(level_select)

func _unhandled_input(event: InputEvent) -> void:
	if wave_manager.is_wave_active:
		if event.is_action_pressed("pause"):
			recipe_ui.pause()

func _setup_map():
	map = current_level.instantiate() as Map
	wave_manager.setup(map)
	_move_players_to_map(map)

func _move_players_to_map(m: Map) -> void:
	for player in player_root.get_children():
		if not player is FPSPlayer: continue

		player.reset()
		player.global_position = m.get_spawn_position(player.player_num)
