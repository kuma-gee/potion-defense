class_name ItemPopup
extends Sprite3D

@export var cauldron_item: CauldronItem
@onready var sub_viewport: SubViewport = $SubViewport

func _ready() -> void:
	texture = sub_viewport.get_texture()

func set_item(item: ItemResource):
	cauldron_item.item = item
	visible = item != null

func get_item_texture():
	if not has_item(): return null
	return cauldron_item.item.texture

func has_item():
	return cauldron_item.item
