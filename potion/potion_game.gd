class_name PotionGame
extends Node3D

@export var souls_label: Label
@export var recipe_ui: RecipeBookUI
@export var gameover: GameoverScreen
@export var shop: Shop
@export var new_recipe: NewRecipe
@export var recipes_btn: Control

@onready var wave_manager: WaveManager = $WaveManager
@onready var player_root: Node3D = $PlayerRoot
@onready var map_root: Node3D = $MapRoot
@onready var in_game_canvas: CanvasLayer = $InGameCanvas
@onready var player_join: PlayerJoin = $PlayerJoin

@export var current_level: PackedScene

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
		souls_label.text = "%s" % v

var unlocked_recipes: Array[ItemResource.Type] = []
var unlocked_upgrades := []

func _ready() -> void:
	_setup_map()
	recipes_btn.hide()
	wave_manager.all_waves_completed.connect(_on_all_waves_completed)
	Events.soul_collected.connect(func(): souls += 1)
	Events.level_started.connect(func(scene: PackedScene):
		current_level = scene
		_setup_map()
	)
	Events.cauldron_used.connect(func():
		if wave_manager.can_start_wave():
			wave_manager.next_wave()
	)
	Events.picked_up_recipe.connect(func(item: ItemResource):
		var type = item.type
		if not type in unlocked_recipes:
			unlocked_recipes.append(type)
			recipe_ui.update_unlocked(unlocked_recipes)
			new_recipe.open(item)
			recipes_btn.show()
			print("Unlocked recipes: %s" % unlocked_recipes)
	)
	Events.buy_upgrade.connect(func(up: UpgradeResource):
		if not up in unlocked_upgrades and souls >= up.price:
			souls -= up.price
			unlocked_upgrades.append(up)
			print("Unlocked upgrades: %s" % unlocked_upgrades)
	)
	
	gameover.restart_level.connect(func(): _setup_map())
	gameover.back_to_select.connect(func(): pass)

func _on_all_waves_completed() -> void:
	shop.open(map.upgrades)
	map.map_finished()

#func back_to_level_select():
	#wave_manager.clear()
	#map = null
	#level_select.process_mode = Node.PROCESS_MODE_INHERIT
	#level_select.position.y = 0
	#_move_players_to_map(level_select)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("recipes"):
		recipe_ui.pause()
	elif map and not wave_manager.is_wave_active:
		if event.is_pressed():
			player_join.spawn_player(event, map)

func _setup_map():
	map = current_level.instantiate() as Map
	wave_manager.setup(map)
	_move_players_to_map(map)

func _move_players_to_map(m: Map) -> void:
	for player in player_root.get_children():
		if not player is FPSPlayer: continue

		player.reset()
		player.global_position = m.get_spawn_position(player.player_num)
