class_name UnlockedItem
extends FocusDialog

@export var texture_rect: TextureRect
@export var label: Label

func unlocked_item(item: ItemResource.Type):
	var res = ItemResource.get_resource(item)
	texture_rect.texture = res.texture
	label.text = "%s" % res.name
	grab_focus()

func _gui_input(event: InputEvent) -> void:
	super(event)
	
	if event is InputEventMouseButton:
		get_viewport().gui_release_focus()
