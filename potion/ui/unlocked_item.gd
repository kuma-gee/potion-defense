class_name UnlockedItem
extends ColorRect

signal closed()

@export var texture_rect: TextureRect
@export var label: Label

func _ready() -> void:
	hide()
	focus_mode = Control.FOCUS_ALL
	focus_entered.connect(func(): show())
	focus_exited.connect(func(): 
		hide()
		closed.emit()
	)

func unlocked_item(item: ItemResource.Type):
	texture_rect.texture = ResourceLoader.load(ItemResource.get_image_path(item))
	label.text = "Unlocked: %s" % ItemResource.build_name(item)
	grab_focus()

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().gui_release_focus()

	get_viewport().set_input_as_handled()
