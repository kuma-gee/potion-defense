class_name RecipeItem
extends VBoxContainer

@export var base: CauldronItem
@export var action: TextureRect
@export var main: CauldronItem

var type: ItemResource.Type

func _ready() -> void:
	var base_type = ItemResource.find_base_type(type)
	if base_type != null:
		base.item = ItemResource.get_resource(base_type)
		var action_type = ItemResource.find_process_for(base_type, type)
		action.texture = ItemResource.PROCESS_ICONS.get(action_type, null)

	base.visible = base_type != null
	action.visible = base_type != null
	main.item = ItemResource.get_resource(type)
