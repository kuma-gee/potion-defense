class_name GameoverScreen
extends Control

signal restart_level()
signal back_to_select()

@export var restart_btn: Button
@export var back_btn: Button

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	back_btn.pressed.connect(func():
		back_to_select.emit()
		resume()
	)
	restart_btn.pressed.connect(func():
		restart_level.emit()
		resume()
	)

func resume():
	get_tree().paused = false
	hide()

func show_gameover() -> void:
	get_tree().paused = true
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
