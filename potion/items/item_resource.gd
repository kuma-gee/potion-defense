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
	Type.POTION_FIRE_BOMB: [Type.RED_HERB, Type.SULFUR],
	Type.POTION_ICE_SHARD: [Type.BLUE_CRYSTAL, Type.WATER],
	Type.POTION_POISON_CLOUD: [Type.GREEN_MOSS, Type.SPIDER_VENOM],
	Type.POTION_PARALYSIS: [Type.WHITE_FLOWER, Type.SPRING_WATER],
}

static func is_empty_potion(type: ItemResource.Type):
	return type == Type.POTION_EMPTY

static func is_potion(type: ItemResource.Type):
	return build_name(type).begins_with("Potion")

static func build_name(type: ItemResource.Type):
	return Type.keys()[type].to_lower().replace("_", " ").capitalize()

static func find_recipe(items: Array):
	for result in RECIPIES.keys():
		var required_items = RECIPIES[result]
		if required_items.size() != items.size():
			continue

		var all_found = true
		for item in required_items:
			if not item in items:
				all_found = false
				break

		if all_found:
			return result

	return null
