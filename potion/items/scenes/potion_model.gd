extends Node3D

@export var liquid_mesh: MeshInstance3D

var type: ItemResource.Type:
	set(v):
		type = v
		if is_inside_tree():
			_update_liquid_color()

func _ready() -> void:
	_update_liquid_color()

func _update_liquid_color() -> void:
	if not liquid_mesh:
		return
	
	var material := liquid_mesh.get_surface_override_material(0) as StandardMaterial3D
	if not material:
		material = StandardMaterial3D.new()
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		liquid_mesh.set_surface_override_material(0, material)
	
	# Set color
	var color: Color = CauldronItem.POTION_COLORS.get(type, Color.WHITE)
	material.albedo_color = color
	
	# Set emission
	var emission: Color = color
	if emission.a > 0:
		material.emission_enabled = true
		material.emission = emission
		material.emission_energy_multiplier = 2.0
	else:
		material.emission_enabled = false
