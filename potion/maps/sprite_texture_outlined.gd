class_name SpriteTextureOutlined
extends Sprite3D

func _ready() -> void:
	change_texture(texture)
	
func change_texture(tex):
	material_override.set_shader_parameter("sprite_texture", tex)
