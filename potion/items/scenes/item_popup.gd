class_name ItemPopup
extends Sprite3D

@export var cauldron_item: CauldronItem
@onready var sub_viewport: SubViewport = $SubViewport

func _ready() -> void:
	texture = sub_viewport.get_texture()

func set_type(type: ItemResource.Type):
	cauldron_item.type = type
	visible = type >= 0

func get_item_texture():
	if not has_item(): return null
	return cauldron_item.item.texture

func has_item():
	return cauldron_item.item
