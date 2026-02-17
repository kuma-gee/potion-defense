class_name Menu
extends Control

@export var continue_btn: BaseButton
@export var restart_btn: BaseButton
@export var back_btn: BaseButton
@export var ui: Control

@onready var main: CenterContainer = $Main

var current_menu: Control

func _ready() -> void:
	hide()
	restart_btn.pressed.connect(func(): SceneManager.restart_current())
	continue_btn.pressed.connect(func(): hide())
	back_btn.pressed.connect(func(): SceneManager.change_to_map_select())
	
	visibility_changed.connect(_on_visibility_changed)

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		hide()
		get_viewport().set_input_as_handled()

func show_main():
	show()
	ui.show()

func hide_main():
	ui.hide()
	hide()

func _on_visibility_changed() -> void:
	get_tree().paused = visible
