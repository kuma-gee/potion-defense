class_name PotionGame
extends Node3D

@export var souls_label: Label
@export var recipe_ui: RecipeBookUI
@export var gameover: GameoverScreen
@export var new_recipe: NewRecipe
@export var in_game_canvas: Control
@export var controls_ui: Control
@export var menu: Menu
@export var join: Control
@export var cauldron: Control
@export var cauldron_health_bar: ProgressBar

@onready var wave_manager: WaveManager = $WaveManager
@onready var player_root: Node3D = $PlayerRoot
@onready var map_root: Node3D = $MapRoot
@onready var player_join: PlayerJoin = $PlayerJoin
@onready var shop: ShopMap = $Shop

var map: Map:
	set(v):
		map = v
		in_game_canvas.visible = map != null
		for child in map_root.get_children():
			child.queue_free()
		
		if map:
			map_root.add_child(map)

func _ready() -> void:
	get_tree().paused = false
	_setup_map()
	
	wave_manager.all_waves_completed.connect(_on_all_waves_completed)
	Events.souls_changed.connect(func(): souls_label.text = "%s" % Events.total_souls)
	Events.move_to_shop.connect(_move_to_shop)
	Events.cauldron_used.connect(func():
		if wave_manager.can_start_wave():
			wave_manager.next_wave()
	)
	Events.picked_up_recipe.connect(_unlocked_recipe)
	shop.next_level.connect(func():
		SceneManager.transition(func(): _setup_map())
	)
	
	menu.restart.connect(func(): _restart_level())
	gameover.restart_level.connect(func(): _restart_level())
	gameover.back_to_select.connect(func(): _back_to_map())

	cauldron.visible = not Events.is_tutorial_level()
	join.visible = Events.is_tutorial_level()
	if Events.is_tutorial_level():
		wave_manager.wave_started.connect(func(): 
			if cauldron.visible: return
			_move_join_container_out()
		)

	if not Events.shown_inputs:
		controls_ui.grab_focus()
		controls_ui.focus_exited.connect(func():
			if not Events.shown_inputs:
				Events.shown_inputs = true
				get_tree().paused = false
		)
		get_tree().paused = true

func _restart_level():
	SceneManager.restart_current()

func _back_to_map():
	SceneManager.change_to_map_select()

func _move_join_container_out():
	var tw = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tw.tween_property(join, "position:y", -50, 0.5)
	_move_cauldron_container_in()
	
func _move_cauldron_container_in():
	var tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	cauldron.position.y = -50
	tw.tween_property(cauldron, "position:y", 0, 0.5)
	cauldron.show()

func _unlocked_recipe(item: ItemResource):
	new_recipe.open(item)
	recipe_ui.update_unlocked(Events.unlocked_recipes)

func _on_all_waves_completed() -> void:
	map.map_finished()

func _move_to_shop():
	SceneManager.transition(func():
		shop.process_mode = Node.PROCESS_MODE_INHERIT
		shop.position.y = 0
		shop.show()
		shop.setup(map)
		
		map = null
		_move_players_to_map(shop)
	)
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed() and event is InputEventKey and event.keycode == KEY_F1:
		Events.level += 1
		_move_to_shop()
	
	if event.is_action_pressed("recipes"):
		recipe_ui.pause()
	elif event.is_action_pressed("ui_cancel") and not menu.visible:
		menu.show()
	else: #if not wave_manager.is_wave_active:
		var m = map if map else shop
		if event.is_pressed():
			player_join.spawn_player(event, m)

func _setup_map():
	shop.process_mode = Node.PROCESS_MODE_DISABLED
	shop.position.y = 1000
	shop.hide()
	
	map = Events.get_current_map().instantiate() as Map
	wave_manager.setup(map)
	_move_players_to_map(map)

	var c = get_tree().get_first_node_in_group("cauldron") as Cauldron
	c.setup_health_bar(cauldron_health_bar)
	
	if not Events.is_tutorial_level():
		wave_manager.next_wave()

func _move_players_to_map(m: Map) -> void:
	for player in player_root.get_children():
		if not player is FPSPlayer: continue

		player.reset()
		player.global_position = m.get_spawn_position(player.player_num)
