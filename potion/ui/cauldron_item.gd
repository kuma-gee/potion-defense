class_name CauldronItem
extends Control

@export var texture_rect: TextureRect
@export var label: Label

var item: ItemResource:
	set(v):
		item = v
		visible = item != null
		if item != null:
			texture_rect.texture = item.texture
			set_potion_color()
		else:
			item = null
			texture_rect.texture = null

var count := 0:
	set(v):
		count = v
		label.visible = count > 1
		label.text = "%sx" % count

func _ready() -> void:
	self.item = item
	label.hide()

func set_potion_color() -> void:
	if not item: return

	var potion = item as PotionResource
	var color := Color.WHITE
	if potion:
		color = potion.color
	var mat = texture_rect.material as ShaderMaterial
	mat.set_shader_parameter("enabled", color != null)
	mat.set_shader_parameter("color", color)
