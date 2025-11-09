class_name FocusDialog
extends Control

signal closed()

func _ready() -> void:
	hide()
	focus_mode = Control.FOCUS_ALL
	focus_entered.connect(func():
		show()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	)
	focus_exited.connect(func(): 
		hide()
		closed.emit()
	)

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("back"):
		get_viewport().gui_release_focus()

	# Leave release, so players actually stop
	if event.is_pressed():
		get_viewport().set_input_as_handled()
