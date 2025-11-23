class_name CauldronItem
extends Control

const POTION_COLORS = {
	ItemResource.Type.POTION_FIRE_BOMB: Color.RED,
	ItemResource.Type.POTION_SLIME: Color.CYAN,
	ItemResource.Type.POTION_POISON_CLOUD: Color.GREEN,
}

@export var texture_rect: TextureRect

var item: ItemResource:
	set(v):
		item = v
		if item != null:
			texture_rect.texture = item.texture
			set_potion_color()
		else:
			item = null
			texture_rect.texture = null

var count := 0:
	set(v):
		count = v
		get_label().text = "%sx" % count

func _ready() -> void:
	self.item = item

func get_label() -> Label:
	return $Label

func set_potion_color() -> void:
	if not item: return

	var color = POTION_COLORS.get(item.type)
	var mat = texture_rect.material as ShaderMaterial
	mat.set_shader_parameter("enabled", color != null)
	if color:
		mat.set_shader_parameter("color", color)
