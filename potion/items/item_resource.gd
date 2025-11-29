class_name ItemResource
extends Resource

enum Type {
	RED_HERB, # Fire
	CHARCOAL, # Explosion
	ICE_SHARD, # Frost (Slow)
	MUSHROOM, # Poison (DPS)
	ICE_SHARD_CRUSHED,

	# So the enum values of the recipies dont change everytime
	WOOD,
	WOOD_CRUSHED,
	RED_HERB_CRUSHED,
	MUSHROOM_CRUSHED,
	PLACEHOLDER_5,
	PLACEHOLDER_6,
	PLACEHOLDER_7,
	PLACEHOLDER_8,
	PLACEHOLDER_9,
	PLACEHOLDER_10,
	PLACEHOLDER_11,
	PLACEHOLDER_12,
	PLACEHOLDER_13,
	PLACEHOLDER_14,
	PLACEHOLDER_15,
	PLACEHOLDER_16,
	PLACEHOLDER_17,
	PLACEHOLDER_18,
	PLACEHOLDER_19,
	PLACEHOLDER_20,
	
	POTION_FIRE_BOMB,
	POTION_SLIME,
	POTION_BLIZZARD,
	POTION_POISON_CLOUD,
	POTION_PARALYSIS,
	POTION_LAVA_FIELD,
	POTION_LIGHTNING,
	PLACEHOLDER_21,
	PLACEHOLDER_22,
	PLACEHOLDER_23,
	PLACEHOLDER_24,
	PLACEHOLDER_25,
	PLACEHOLDER_26,
}

const RECIPIES = {
	Type.POTION_FIRE_BOMB: {Type.RED_HERB: 1, Type.CHARCOAL: 1},
	Type.POTION_SLIME: {Type.WOOD_CRUSHED: 1, Type.RED_HERB: 1},
	Type.POTION_POISON_CLOUD: {Type.CHARCOAL: 1, Type.RED_HERB: 1, Type.MUSHROOM_CRUSHED: 1},

	#Type.POTION_BLIZZARD: {Type.CHARCOAL: 1, Type.RED_HERB: 1, Type.MUSHROOM_CRUSHED: 1},

	# Type.POTION_LIGHTNING: {Type.POTION_PARALYSIS: 1, Type.CHARCOAL: 1},
	# Type.POTION_BLIZZARD: {Type.POTION_SLIME: 1, Type.MUSHROOM: 1},

	# Type.POTION_PARALYSIS: {Type.ICE_SHARD: 2, Type.VULCANIC_ASH: 1},
	# Type.POTION_LAVA_FIELD: {Type.POTION_FIRE_BOMB: 1, Type.VULCANIC_ASH: 1},
}

@export var type: Type = Type.RED_HERB
@export var max_capacity: int = 4
@export var restore_time: float = 5.0
@export var texture: Texture2D

var name: String = "":
	get():
		return build_name(type)

static func is_potion(t: ItemResource.Type):
	return build_name(t).begins_with("Potion")

static func build_name(t: ItemResource.Type):
	return Type.keys()[t].to_lower().replace("_", " ").capitalize()

static func get_resource(t: ItemResource.Type) -> ItemResource:
	var res_path = "res://potion/items/resources/%s.tres" % build_name(t).to_lower().replace(" ", "_")
	return ResourceLoader.load(res_path) as ItemResource

static func find_potential_recipe(items: Array, exact = false):
	for result in RECIPIES.keys():
		var required_items = RECIPIES[result]
		
		var item_counts: Dictionary = {}
		for item in items:
			item_counts[item] = item_counts.get(item, 0) + 1
		
		var all_found = true
		
		if exact:
			# Loop required items to find the exact one
			for item_type in required_items.keys():
				if not item_counts.has(item_type):
					all_found = false
					break
					
				var required_count = required_items[item_type]
				var available_count = item_counts.get(item_type)
				if available_count != required_count:
					all_found = false
					break
		else:
			# Loop current items to check if valid recipes exist
			for item_type in item_counts.keys():
				if not required_items.has(item_type):
					all_found = false
					break
				
				var required_count = required_items[item_type]
				var available_count = item_counts.get(item_type)
				if available_count > required_count:
					all_found = false
					break
		
		if all_found:
			return result

	return null

func is_potion_item():
	return ItemResource.is_potion(type)
