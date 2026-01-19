class_name GameoverScreen
extends Control

@export var restart_btn: Button
@export var back_btn: Button

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	back_btn.pressed.connect(func(): SceneManager.change_to_map_select())
	restart_btn.pressed.connect(func(): SceneManager.restart_current())

func show_gameover() -> void:
	get_tree().paused = true
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
