class_name PotionGame
extends Node3D

@export var souls_label: Label
@export var recipe_ui: RecipeBookUI
@export var gameover: GameoverScreen
@export var new_recipe: NewRecipe
@export var recipes_btn: Control

@onready var wave_manager: WaveManager = $WaveManager
@onready var player_root: Node3D = $PlayerRoot
@onready var map_root: Node3D = $MapRoot
@onready var in_game_canvas: CanvasLayer = $InGameCanvas
@onready var player_join: PlayerJoin = $PlayerJoin
@onready var shop: ShopMap = $Shop

@export var current_level: PackedScene

var map: Map:
	set(v):
		map = v
		in_game_canvas.visible = map != null
		for child in map_root.get_children():
			child.queue_free()
		
		if map:
			map_root.add_child(map)

func _ready() -> void:
	_setup_map()
	recipes_btn.hide()
	wave_manager.all_waves_completed.connect(_on_all_waves_completed)
	Events.souls_changed.connect(func(): souls_label.text = "%s" % Events.total_souls)
	Events.level_started.connect(_move_to_shop)
	Events.cauldron_used.connect(func():
		if wave_manager.can_start_wave():
			wave_manager.next_wave()
	)
	Events.picked_up_recipe.connect(_unlocked_recipe)
	shop.next_level.connect(func(): _setup_map())
	
	gameover.restart_level.connect(func(): _setup_map())
	gameover.back_to_select.connect(func(): pass)

func _unlocked_recipe(item: ItemResource):
	new_recipe.open(item)
	recipe_ui.update_unlocked(Events.unlocked_recipes)
	recipes_btn.show()

func _on_all_waves_completed() -> void:
	map.map_finished()

func _move_to_shop(next_map: PackedScene):
	current_level = next_map
	
	shop.process_mode = Node.PROCESS_MODE_INHERIT
	shop.position.y = 0
	shop.show()
	shop.setup(map.upgrades)
	
	map = null
	_move_players_to_map(shop)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed() and event is InputEventKey and event.keycode == KEY_F1:
		_move_to_shop(map.level.map)
	
	if event.is_action_pressed("recipes"):
		recipe_ui.pause()
	elif not wave_manager.is_wave_active:
		var m = map if map else shop
		if event.is_pressed():
			player_join.spawn_player(event, m)

func _setup_map():
	shop.process_mode = Node.PROCESS_MODE_DISABLED
	shop.position.y = 1000
	shop.hide()
	
	map = current_level.instantiate() as Map
	wave_manager.setup(map)
	_move_players_to_map(map)

	if not Events.is_tutorial_level():
		wave_manager.next_wave()

func _move_players_to_map(m: Map) -> void:
	for player in player_root.get_children():
		if not player is FPSPlayer: continue

		player.reset()
		player.global_position = m.get_spawn_position(player.player_num)
