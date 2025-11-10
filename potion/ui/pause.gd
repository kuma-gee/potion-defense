class_name Pause
extends Control

@export var game: PotionGame
@export var continue_btn: Button
@export var restart_btn: Button

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	restart_btn.pressed.connect(func():
		close()
		game.stop_wave()
	)
	continue_btn.pressed.connect(func(): close())
	visibility_changed.connect(func():
		get_tree().paused = visible
	)

func _unhandled_input(event: InputEvent) -> void:
	if visible and (event.is_action_pressed("pause") or event.is_action_pressed("back")):
		close()

func pause() -> void:
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func close():
	hide()
