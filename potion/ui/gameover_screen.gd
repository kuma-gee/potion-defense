class_name GameoverScreen
extends Control

@export var restart_btn: Button

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	restart_btn.pressed.connect(func(): get_tree().reload_current_scene())

func show_gameover() -> void:
	get_tree().paused = true
	show()
