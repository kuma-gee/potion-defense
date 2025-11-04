class_name ItemButton
extends TextureButton

@export var texture: TextureRect
@export var label: Label

var type: ItemResource.Type

func _ready() -> void:
	texture.texture = ResourceLoader.load(ItemResource.get_image_path(type))
	label.text = ItemResource.build_name(type)
