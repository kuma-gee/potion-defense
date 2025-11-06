class_name UnlockedItem
extends FocusDialog

@export var texture_rect: TextureRect
@export var label: Label

func unlocked_item(item: ItemResource.Type):
	texture_rect.texture = ResourceLoader.load(ItemResource.get_image_path(item))
	label.text = "%s" % ItemResource.build_name(item)
	grab_focus()
