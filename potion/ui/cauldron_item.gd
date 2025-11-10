class_name CauldronItem
extends TextureRect

var type: ItemResource.Type:
	set(v):
		type = v
		if type >= 0:
			texture = ItemResource.get_resource(type).texture
		else:
			texture = null

var count := 0:
	set(v):
		count = v
		get_label().text = "%sx" % count

func _ready() -> void:
	self.type = type

func get_label() -> Label:
	return $Label
