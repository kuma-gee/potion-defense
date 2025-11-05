class_name ItemResource
extends Resource

enum Type {
	RED_HERB,
	SULFUR,
	BLUE_CRYSTAL,
	WATER,
	GREEN_MOSS,
	SPIDER_VENOM,
	WHITE_FLOWER,
	SPRING_WATER,
	
	POTION_EMPTY,
	POTION_FIRE_BOMB,
	POTION_ICE_SHARD,
	POTION_POISON_CLOUD,
	POTION_PARALYSIS,
}

const RECIPIES = {
	Type.POTION_FIRE_BOMB: {Type.RED_HERB: 1, Type.SULFUR: 1},
	Type.POTION_ICE_SHARD: {Type.BLUE_CRYSTAL: 1, Type.WATER: 1},
	Type.POTION_POISON_CLOUD: {Type.GREEN_MOSS: 1, Type.SPIDER_VENOM: 1},
	Type.POTION_PARALYSIS: {Type.WHITE_FLOWER: 1, Type.SPRING_WATER: 1},
}

# Map item types to their 3D scenes
const ITEM_SCENES = {
	Type.RED_HERB: preload("res://potion/items/scenes/red_herb.tscn"),
	Type.SULFUR: preload("res://potion/items/scenes/sulfur.tscn"),
	Type.BLUE_CRYSTAL: preload("res://potion/items/scenes/blue_crystal.tscn"),
	Type.WATER: preload("res://potion/items/scenes/water.tscn"),
	Type.GREEN_MOSS: preload("res://potion/items/scenes/green_moss.tscn"),
	Type.SPIDER_VENOM: preload("res://potion/items/scenes/spider_venom.tscn"),
	Type.WHITE_FLOWER: preload("res://potion/items/scenes/white_flower.tscn"),
	Type.SPRING_WATER: preload("res://potion/items/scenes/spring_water.tscn"),
	Type.POTION_EMPTY: preload("res://potion/items/scenes/potion_empty.tscn"),
}

@export var type: Type = Type.RED_HERB
@export var name: String = ""
@export var description: String = ""
@export var max_capacity: int = 4
@export var restore_time: float = 5.0

static func get_item_scene(t: ItemResource.Type) -> PackedScene:
	if is_potion(t):
		return ITEM_SCENES[Type.POTION_EMPTY]

	if t in ITEM_SCENES:
		return ITEM_SCENES[t]
	return null

static func is_empty_potion(t: ItemResource.Type):
	return t == Type.POTION_EMPTY

static func is_potion(t: ItemResource.Type):
	return build_name(t).begins_with("Potion")

static func build_name(t: ItemResource.Type):
	return Type.keys()[t].to_lower().replace("_", " ").capitalize()

static func get_image_path(t: ItemResource.Type) -> String:
	return "res://potion/items/images/%s.png" % build_name(t).to_lower().replace(" ", "_")

static func find_recipe(items: Array):
	for result in RECIPIES.keys():
		var required_items = RECIPIES[result]
		
		var item_counts: Dictionary = {}
		for item in items:
			item_counts[item] = item_counts.get(item, 0) + 1
		
		var all_found = true
		for item_type in required_items.keys():
			var required_count = required_items[item_type]
			var available_count = item_counts.get(item_type, 0)
			
			if available_count < required_count:
				all_found = false
				break
		
		if all_found:
			return result

	return null
