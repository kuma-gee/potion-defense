class_name ItemResource
extends Resource

enum Type {
	RED_HERB, # Fire
	CHARCOAL, # Explosion
	ICE_SHARD, # Frost (Slow)
	SPIDER_VENOM, # Poison (DPS)
	VULCANIC_ASH,
	
	POTION_FIRE_BOMB,
	POTION_FROST_NOVA,
	POTION_BLIZZARD,
	POTION_POISON_CLOUD,
	POTION_PARALYSIS,
	POTION_LAVA_FIELD,
	POTION_LIGHTNING,
}

const RECIPIES = {
	Type.POTION_FIRE_BOMB: {Type.RED_HERB: 2, Type.CHARCOAL: 1},
	Type.POTION_FROST_NOVA: {Type.ICE_SHARD: 2},
	Type.POTION_POISON_CLOUD: {Type.RED_HERB: 1, Type.ICE_SHARD: 1, Type.SPIDER_VENOM: 1},
	Type.POTION_PARALYSIS: {Type.ICE_SHARD: 2, Type.VULCANIC_ASH: 1},

	Type.POTION_BLIZZARD: {Type.POTION_FROST_NOVA: 1, Type.SPIDER_VENOM: 1},
	Type.POTION_LAVA_FIELD: {Type.POTION_FIRE_BOMB: 1, Type.VULCANIC_ASH: 1},
	Type.POTION_LIGHTNING: {Type.POTION_PARALYSIS: 1, Type.CHARCOAL: 1},
}


@export var type: Type = Type.RED_HERB
@export var name: String = ""
@export var max_capacity: int = 4
@export var restore_time: float = 5.0
@export var texture: Texture2D

static func is_potion(t: ItemResource.Type):
	return build_name(t).begins_with("Potion")

static func build_name(t: ItemResource.Type):
	return Type.keys()[t].to_lower().replace("_", " ").capitalize()

static func get_image_path(t: ItemResource.Type) -> String:
	return "res://potion/items/images/%s.png" % build_name(t).to_lower().replace(" ", "_")

static func get_resource(t: ItemResource.Type) -> ItemResource:
	var res_path = "res://potion/items/resources/%s.tres" % build_name(t).to_lower().replace(" ", "_")
	return ResourceLoader.load(res_path) as ItemResource

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

func is_potion_item():
	return ItemResource.is_potion(type)
