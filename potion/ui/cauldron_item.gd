extends TextureRect

var type: ItemResource.Type
var count := 0:
	set(v):
		count = v
		$Label.text = "%sx" % count

func _ready() -> void:
	texture = ItemResource.get_resource(type).texture
