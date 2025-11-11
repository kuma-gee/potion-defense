class_name CauldronItem
extends TextureRect

var item: ItemResource
var type: ItemResource.Type:
	set(v):
		type = v
		if type >= 0:
			item = ItemResource.get_resource(type)
			texture = item.texture
		else:
			item = null
			texture = null

var count := 0:
	set(v):
		count = v
		get_label().text = "%sx" % count

func _ready() -> void:
	self.type = type

func get_label() -> Label:
	return $Label
