class_name ItemButton
extends TextureButton

@export var texture: TextureRect
@export var label: Label

var res: ItemResource:
	set(v):
		res = v
		texture.visible = res != null
		label.visible = texture.visible
		if res:
			texture.texture = res.texture
			label.text = res.name
		
var locked := false:
	set(v):
		locked = v
		label.visible = not locked
		modulate = Color(0.2,0.2,0.2) if locked else Color.WHITE
		disabled = locked
