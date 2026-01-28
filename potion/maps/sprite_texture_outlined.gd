extends Sprite3D

func _ready() -> void:
	material_override.set_shader_parameter("sprite_texture", texture)
