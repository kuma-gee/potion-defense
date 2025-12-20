class_name ControlsMenu
extends Control

@export var pages: Array[Control]
@export var label: Label
@export var prev_btn: Control
@export var next_btn: Control

var page_index := 0
var labels = ["Keyboard", "Controller"]

func _ready() -> void:
	hide()
	_change_page(0)
	focus_entered.connect(func(): show())
	focus_exited.connect(func(): hide())

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_right"):
		_change_page(1)
	elif event.is_action_pressed("ui_left"):
		_change_page(-1)
	elif event.is_action_pressed("back"):
		get_viewport().gui_release_focus()
	
	get_viewport().set_input_as_handled()

func _change_page(direction: int) -> void:
	page_index += direction
	page_index = clamp(page_index, 0, pages.size() - 1)

	for i in range(pages.size()):
		pages[i].visible = (i == page_index)
	
	label.text = "%s" % labels[page_index]
	prev_btn.text = " " if page_index == 0 else "<"
	next_btn.text = " " if page_index == pages.size() - 1 else ">"
