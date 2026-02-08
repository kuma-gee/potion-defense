class_name PotionGame
extends Node3D

@export var recipe_ui: RecipeBookUI
@export var gameover: GameoverScreen
@export var new_recipe: NewRecipe
@export var recipe_container: Control
@export var in_game_canvas: Control
@export var menu: Menu
@export var cauldron: Control
@export var cauldron_health_bar: ProgressBar
@export var notific: Notification

@onready var wave_manager: WaveManager = $WaveManager
@onready var player_root: Node3D = $PlayerRoot
@onready var map_root: Node3D = $MapRoot
@onready var player_join: PlayerJoin = $PlayerJoin

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
	Events.cauldron_used.connect(func():
		if wave_manager.can_start_wave():
			wave_manager.next_wave()
	)
	wave_manager.wave_started.connect(func(): notific.show_text("Wave %s incoming!" % wave_manager.wave))
	Events.picked_up_recipe.connect(_unlocked_recipe)
	Events.has_played = true
	recipe_container.visible = not Events.unlocked_recipes.is_empty()

func _unlocked_recipe(item: ItemResource):
	new_recipe.open(item)
	recipe_ui.update_unlocked(Events.unlocked_recipes)
	recipe_container.show()

func _on_all_waves_completed() -> void:
	map.map_finished()
	wave_manager.clear()
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed() and event is InputEventKey:
		if event.keycode == KEY_F1:
			Events.level += 1
			_on_all_waves_completed()
		elif event.keycode == KEY_F2:
			Events.collect_soul(1000)
		elif event.keycode == KEY_F3:
			Events.enemy_move_speed_multipler += 0.5 * (-1.0 if event.shift_pressed else 1.0)
	
	if event.is_action_pressed("recipes"):
		recipe_ui.pause()
	elif event.is_action_pressed("ui_cancel"):
		if menu.visible:
			menu.hide_main()
		else:
			menu.show_main()

func _setup_map():
	map = Events.get_current_map().instantiate() as Map
	wave_manager.setup(map)
	for p in Events.players:
		player_join.setup_player(p, map.spawn_point.global_position)

	var c = get_tree().get_first_node_in_group("cauldron") as Cauldron
	c.setup_health_bar(cauldron_health_bar)
