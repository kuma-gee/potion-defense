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

static func get_item_scene(type: ItemResource.Type) -> PackedScene:
	if is_potion(type):
		return ITEM_SCENES[Type.POTION_EMPTY]

	if type in ITEM_SCENES:
		return ITEM_SCENES[type]
	return null

static func is_empty_potion(type: ItemResource.Type):
	return type == Type.POTION_EMPTY

static func is_potion(type: ItemResource.Type):
	return build_name(type).begins_with("Potion")

static func build_name(type: ItemResource.Type):
	return Type.keys()[type].to_lower().replace("_", " ").capitalize()

static func get_image_path(type: ItemResource.Type) -> String:
	return "res://potion/items/images/%s.png" % build_name(type).to_lower().replace(" ", "_")

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
