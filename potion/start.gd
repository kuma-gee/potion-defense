extends Control

@export var new_button: Button
@export var continue_button: Button
@export var settings_button: Button
@export var exit_button: Button

func _ready() -> void:
	get_tree().paused = false

	if not Events.shown_inputs:
		_on_new_pressed(true)
		return
	
	new_button.pressed.connect(_on_new_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func _on_new_pressed(initial = false) -> void:
	SceneManager.change_to_game(0, initial)

func _on_continue_pressed() -> void:
	SceneManager.change_to_map_select()

func _on_settings_pressed() -> void:
	pass

func _on_exit_pressed() -> void:
	SceneManager.exit_game()
