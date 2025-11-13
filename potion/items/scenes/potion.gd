class_name Potion
extends CollisionShape3D

signal hit()

@export var potion_type := ItemResource.Type.POTION_FIRE_BOMB
@export var liquid_mesh: MeshInstance3D
@onready var hit_area: Area3D = $HitArea

const EFFECT_SCENES = {
	ItemResource.Type.POTION_FIRE_BOMB: preload("uid://bnh078xxhjtqf"),
	ItemResource.Type.POTION_FROST_NOVA: preload("uid://df2iboydwrtbj"),
	ItemResource.Type.POTION_POISON_CLOUD: preload("uid://cvrm4vmap3w15"),
	ItemResource.Type.POTION_PARALYSIS: preload("uid://cckgdr5i01p5d"),
	ItemResource.Type.POTION_BLIZZARD: preload("uid://c684oj6gh0t68"),
	ItemResource.Type.POTION_LAVA_FIELD: preload("uid://vb3dg7vbbfqm"),
	ItemResource.Type.POTION_LIGHTNING: preload("uid://d1n4byccvwsct"),
}

const POTION_COLORS = {
	#ItemResource.Type.POTION_FIRE_BOMB: Color(1.0, 0.3, 0.0, 0.8),  # Orange/Red
	#ItemResource.Type.POTION_FROST_NOVA: Color(0.3, 0.7, 1.0, 0.8),  # Cyan/Blue
	#ItemResource.Type.POTION_POISON_CLOUD: Color(0.2, 0.8, 0.2, 0.8),  # Green
	#ItemResource.Type.POTION_PARALYSIS: Color(0.8, 0.8, 0.3, 0.8),  # Yellow
}

const POTION_EMISSIONS = {
	#ItemResource.Type.POTION_FIRE_BOMB: Color(1.0, 0.5, 0.0, 1.0),  # Orange glow
	#ItemResource.Type.POTION_FROST_NOVA: Color(0.5, 0.8, 1.0, 1.0),  # Blue glow
	#ItemResource.Type.POTION_POISON_CLOUD: Color(0.3, 1.0, 0.3, 1.0),  # Green glow
	#ItemResource.Type.POTION_PARALYSIS: Color(1.0, 1.0, 0.5, 1.0),  # Yellow glow
}

func _ready() -> void:
	_update_liquid_color()
	hit_area.area_entered.connect(func(_a): on_hit())

func is_hitting_enemy():
	return hit_area.has_overlapping_areas()

func set_potion_type(new_type: ItemResource.Type) -> void:
	potion_type = new_type
	if is_inside_tree():
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
	var color: Color = POTION_COLORS.get(potion_type, Color.WHITE)
	material.albedo_color = color
	
	# Set emission
	var emission: Color = POTION_EMISSIONS.get(potion_type, Color.BLACK)
	if emission.a > 0:
		material.emission_enabled = true
		material.emission = emission
		material.emission_energy_multiplier = 2.0
	else:
		material.emission_enabled = false

func on_hit() -> void:
	var node = spawn_effect(potion_type, global_position)
	if node:
		get_tree().current_scene.add_child(node)

	hit.emit()

static func spawn_effect(type: ItemResource.Type, pos: Vector3) -> Node:
	var scene = EFFECT_SCENES.get(type, null)
	if scene:
		var node = scene.instantiate()
		node.position = pos
		return node
	return null
