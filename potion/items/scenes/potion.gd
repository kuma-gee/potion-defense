class_name Potion
extends CollisionShape3D

signal hit()

@export var potion_type := ItemResource.Type.POTION_FIRE_BOMB
@onready var potion_model: Node3D = $PotionModel
@onready var hit_area: Area3D = $HitArea

const EFFECT_SCENES = {
	ItemResource.Type.POTION_FIRE_BOMB: preload("uid://bnh078xxhjtqf"),
	ItemResource.Type.POTION_BLIZZARD: preload("uid://c684oj6gh0t68"),
	ItemResource.Type.POTION_HOLY: preload("uid://cscxdp7clvk3k"),
}

func _ready() -> void:
	potion_model.type = potion_type
	hit_area.area_entered.connect(func(_a): on_hit())

func is_hitting_enemy():
	return hit_area.has_overlapping_areas()

func set_potion_type(new_type: ItemResource.Type) -> void:
	potion_type = new_type
	potion_model.type = potion_type
	if new_type == ItemResource.Type.POTION_HOLY:
		hit_area.collision_mask |= (1 << 12)

func on_hit() -> void:
	var spawn_position = _get_ground_position()
	var node = spawn_effect(potion_type, spawn_position)
	if node:
		get_tree().current_scene.add_child(node)

	hit.emit()

func _get_ground_position() -> Vector3:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, global_position + Vector3.DOWN * 10.0, 1)
	query.exclude = [get_parent()]
	
	var result = space_state.intersect_ray(query)
	if result:
		return result.position
	
	return global_position

static func spawn_effect(type: ItemResource.Type, pos: Vector3) -> Node:
	var scene = EFFECT_SCENES.get(type, null)
	if scene:
		var node = scene.instantiate()
		node.potion = ItemResource.get_resource(type) as PotionResource
		node.position = pos
		return node
	return null
