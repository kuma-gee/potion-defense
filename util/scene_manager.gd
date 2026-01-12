extends Node

const POTION_GAME = preload("uid://bquyk6n7heynp")
const START = preload("uid://d2r2acm4ncnnc")
const MAP_SELECT = preload("uid://ctnqcjceovl8r")

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func change_to_map_select():
	change_scene(MAP_SELECT)

func change_to_start() -> void:
	change_scene(START)

func change_to_game(lvl = -1, initial = false) -> void:
	if lvl >= 0:
		Events.level = lvl
	
	if not initial:
		await start_transition()

	get_tree().change_scene_to_packed(POTION_GAME)
	await get_tree().create_timer(0.5).timeout
	await end_transition()

func change_scene(scene) -> void:
	transition(func(): get_tree().change_scene_to_packed(scene))

func restart_current():
	SceneManager.transition(func(): get_tree().reload_current_scene())

func exit_game():
	transition(func(): get_tree().quit())

func transition(callback: Callable):
	await start_transition()
	await callback.call()
	await get_tree().create_timer(0.5).timeout
	await end_transition()

func start_transition():
	animation_player.play("show")
	await animation_player.animation_finished

func end_transition():
	animation_player.play_backwards("show")
	await animation_player.animation_finished
