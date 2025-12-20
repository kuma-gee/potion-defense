class_name CauldronItem
extends Control

const POTION_COLORS = {
	ItemResource.Type.POTION_FIRE_BOMB: Color.RED,
	ItemResource.Type.POTION_SLIME: Color.BLUE,
	ItemResource.Type.POTION_POISON_CLOUD: Color.SEA_GREEN,
	ItemResource.Type.POTION_LIGHTNING: Color.YELLOW,
	ItemResource.Type.POTION_BLIZZARD: Color.SKY_BLUE,
}

@export var texture_rect: TextureRect
@export var label: Label

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
		label.visible = count > 1
		label.text = "%sx" % count

func _ready() -> void:
	self.item = item
	label.hide()

func set_potion_color() -> void:
	if not item: return

	var color = POTION_COLORS.get(item.type, Color.WHITE)
	var mat = texture_rect.material as ShaderMaterial
	mat.set_shader_parameter("enabled", color != null)
	mat.set_shader_parameter("color", color)
