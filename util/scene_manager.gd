extends Node

const POTION_GAME = preload("uid://bquyk6n7heynp")
const START = preload("uid://d2r2acm4ncnnc")
const MAP_SELECT = preload("uid://ctnqcjceovl8r")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer
@onready var color_rect: ColorRect = $CanvasLayer/ColorRect

var loading := false

func _ready() -> void:
	timer.timeout.connect(func(): end_transition())

func change_to_map_select():
	change_scene(MAP_SELECT)

func change_to_start() -> void:
	change_scene(START)

func change_to_game(lvl = -1, initial = false) -> void:
	if lvl >= 0:
		Events.level = lvl
	
	if not initial:
		await start_transition()

	get_tree().call_deferred("change_scene_to_packed", POTION_GAME)
	timer.start()

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
