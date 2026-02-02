extends Node

const POTION_GAME = "uid://bquyk6n7heynp"
const START = preload("uid://d2r2acm4ncnnc")
const MAP_SELECT = preload("uid://ctnqcjceovl8r")
const SHOP = preload("uid://cnhq46dfc2xlt")

@export var loading_bar: ProgressBar
@export var continue_text: Label

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer
@onready var color_rect: ColorRect = $CanvasLayer/ColorRect
@onready var min_load_timer: Timer = $MinLoadTimer

var target_scene := ""
var loading := false

func _process(_delta: float) -> void:
	_update_loading_progress()

func _ready() -> void:
	animation_player.play_backwards("show_loading")
	target_scene = ""
	continue_text.hide()
	
	timer.timeout.connect(func(): end_transition())
	min_load_timer.timeout.connect(_on_min_loading_timeout)
	BackgroundResourceLoader.resource_loaded.connect(_on_resource_loaded)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and target_scene and continue_text.visible:
		_to_target_scene()

func _on_min_loading_timeout():
	_finish_loading()

func _on_resource_loaded(_path: String, _res: Resource):
	if min_load_timer.is_stopped() and target_scene != "":
		_finish_loading()

func _finish_loading():
	loading_bar.hide()
	continue_text.show()

func _to_target_scene():
	if not target_scene: return
		
	animation_player.play_backwards("show_loading")
	get_tree().change_scene_to_file(target_scene)
	target_scene = ""
	
	await animation_player.animation_finished
	timer.start()
	continue_text.hide()

func _start_loading_to(path: String):
	BackgroundResourceLoader.request_load(POTION_GAME)
	
	loading_bar.show()
	continue_text.hide()
	loading_bar.value = 0.0
	animation_player.play("show_loading")
	await animation_player.animation_finished

	await get_tree().create_timer(0.5).timeout # dont show loading bar immediately
	min_load_timer.start()
	target_scene = path

func _update_loading_progress() -> void:
	if not loading_bar.visible or target_scene == "":
		return
	if min_load_timer.is_stopped():
		loading_bar.value = 1.0
		return
	var wait_time: float = min_load_timer.wait_time
	if wait_time <= 0.0:
		loading_bar.value = 1.0
		return
	loading_bar.value = 1.0 - (min_load_timer.time_left / wait_time)

func change_to_game(lvl = -1) -> void:
	get_tree().paused = true

	if lvl >= 0:
		Events.level = lvl
	
	await start_transition()
	_start_loading_to(POTION_GAME)

func change_to_map_select():
	change_scene(MAP_SELECT)

func change_to_shop():
	change_scene(SHOP)

func change_to_start() -> void:
	change_scene(START)

func change_scene(scene) -> void:
	transition(func(): get_tree().change_scene_to_packed(scene))

func restart_current():
	SceneManager.transition(func(): get_tree().reload_current_scene())

func exit_game():
	transition(func(): get_tree().quit())

func transition(callback: Callable):
	if not timer.is_stopped(): return
	await start_transition()
	await callback.call()
	timer.start()

func start_transition():
	loading = true
	animation_player.play("show")
	await animation_player.animation_finished

func end_transition():
	if color_rect.color != Color.BLACK: return
	
	animation_player.play_backwards("show")
	await animation_player.animation_finished
	loading = false
