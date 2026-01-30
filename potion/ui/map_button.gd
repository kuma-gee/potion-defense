class_name MapButton
extends MoveNext

@export var name_label: Label3D
@export var lock_label: Label3D
@export var original_color := Color.WHITE

var res: MapResource
var is_disabled: bool = false:
	set(v):
		is_disabled = v
		monitoring = not is_disabled
		if lock_label:
			lock_label.visible = is_disabled
		if is_disabled:
			time = 0.0
		_update_material_state()

func _ready() -> void:
	super._ready()
	if res:
		name_label.text = "%s" % res.name
	_update_material_state()

func _update_material_state() -> void:
	if not mesh_instance_3d:
		return
	var material := mesh_instance_3d.material_override as ShaderMaterial
	if not material:
		return
	
	material.set_shader_parameter("albedo", Color.DIM_GRAY if is_disabled else original_color)
