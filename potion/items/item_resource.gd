class_name ItemResource
extends Resource

const ACTION_CRUSH = preload("uid://boip6hxwy0kgr")

enum Type {
	RED_HERB, # Fire
	FROST_MUSHROOM, # Frost
	MOSS, # Poison

	CRYSTAL,
	CRYSTAL_CRUSHED,
	SHARD_FRAGMENT,
	SHARD_FRAGMENT_PULVERIZED,
	
	POTION_FIRE_BOMB,
	POTION_SLIME,
	POTION_BLIZZARD,
	POTION_POISON_CLOUD,
	POTION_PARALYSIS,
	POTION_LAVA_FIELD,
	POTION_LIGHTNING,
}

enum Process {
	CRUSH,
	PULVERIZE,
}

const PROCESS_ICONS = {
	Process.CRUSH: ACTION_CRUSH,
	Process.PULVERIZE: ACTION_CRUSH,
}

const PROCESSES = {
	Process.CRUSH: {
		Type.CRYSTAL: Type.CRYSTAL_CRUSHED,
	},
	Process.PULVERIZE: {
		Type.SHARD_FRAGMENT: Type.SHARD_FRAGMENT_PULVERIZED,
	},
}

const RECIPIES = {
	Type.POTION_FIRE_BOMB: [Type.RED_HERB, Type.CRYSTAL],
	Type.POTION_BLIZZARD: [Type.FROST_MUSHROOM, Type.CRYSTAL_CRUSHED],
	Type.POTION_POISON_CLOUD: [Type.MOSS, Type.MOSS, Type.CRYSTAL],
	Type.POTION_LIGHTNING: [Type.POTION_PARALYSIS, ],

	# Type.POTION_SLIME: [Type.WOOD_CRUSHED, Type.RED_HERB],

	# Type.POTION_BLIZZARD: [Type.POTION_SLIME, Type.MUSHROOM],

	# Type.POTION_PARALYSIS: [Type.ICE_SHARD, Type.ICE_SHARD, Type.VULCANIC_ASH],
	# Type.POTION_LAVA_FIELD: [Type.POTION_FIRE_BOMB, Type.VULCANIC_ASH],
}

var type: Type = Type.RED_HERB:
	get():
		var file_name = resource_path.split("/")[-1].split(".")[0].to_upper()
		var idx = Type.keys().find(file_name)
		if idx == -1:
			return Type.RED_HERB
		return Type.values()[idx]

@export var max_capacity: int = 4
@export var restore_time: float = 5.0
@export var texture: Texture2D
@export var scene: PackedScene

var name: String = "":
	get():
		return build_name(type)

static func find_base_type(i: Type):
	for process in PROCESSES.keys():
		var mapping = PROCESSES[process]
		for base in mapping.keys():
			if mapping[base] == i:
				return base
	return null

static func find_process_for(base: Type, result: Type):
	for process in PROCESSES.keys():
		var mapping = PROCESSES[process]
		if mapping.get(base, null) == result:
			return process
	return null

static func is_potion(t: ItemResource.Type):
	return build_name(t).begins_with("Potion")

static func build_name(t: ItemResource.Type):
	return Type.keys()[t].to_lower().replace("_", " ").capitalize()

static func get_resource(t: ItemResource.Type) -> ItemResource:
	var res_path = "res://potion/items/resources/%s.tres" % Type.keys()[t].to_lower()
	return ResourceLoader.load(res_path) as ItemResource

static func find_potential_recipe(items: Array, exact = false):
	for result in RECIPIES.keys():
		var required_items = RECIPIES[result]
		
		if exact and items.size() != required_items.size():
			continue
		
		if items.size() > required_items.size():
			continue
		
		# Create copies to avoid modifying original arrays
		var items_copy = items.duplicate()
		var required_copy = required_items.duplicate()
		
		# Try to match each item
		var matches = true
		for item in items_copy:
			var idx = required_copy.find(item)
			if idx == -1:
				matches = false
				break
			required_copy.remove_at(idx)

		# Previous exact match, maybe needed again
		# var matches = true
		# for i in range(items.size()):
		# 	if items[i] != required_items[i]:
		# 		matches = false
		# 		break
		
		if matches:
			return result

	return null

func is_potion_item():
	return ItemResource.is_potion(type)
