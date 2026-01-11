class_name Menu
extends Control

signal restart()

@export var continue_btn: Button
@export var restart_btn: Button
@export var quit_btn: Button
@export var recipe_btn: Button
@export var controls_btn: Button

@export var ui: Control
@export var controls: Control
@export var recipe: RecipeBookUI

@onready var main: CenterContainer = $Main

var current_menu: Control

func _ready() -> void:
	hide()
	restart_btn.pressed.connect(func(): restart.emit())
	continue_btn.pressed.connect(func(): hide())
	quit_btn.pressed.connect(func(): get_tree().quit())
	visibility_changed.connect(_on_visibility_changed)
	recipe_btn.pressed.connect(func():
		recipe.grab_focus()
		ui.hide()
	)
	controls_btn.pressed.connect(func():
		controls.grab_focus()
		ui.hide()
	)

	recipe.focus_exited.connect(func(): show_main())
	controls.focus_exited.connect(func(): show_main())

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		hide()
		get_viewport().set_input_as_handled()

func show_main():
	ui.show()
	continue_btn.grab_focus()

func _on_visibility_changed() -> void:
	get_tree().paused = visible
