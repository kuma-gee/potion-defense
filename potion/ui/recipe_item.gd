class_name RecipeItem
extends HBoxContainer

@export var base: CauldronItem
@export var action: TextureRect
@export var main: CauldronItem

var type: ItemResource.Type
var chain_nodes: Array[Node] = []

func _ready() -> void:
	var base_chain: Array[Dictionary] = ItemResource.find_base_type(type)
	clear_chain_nodes()
	base.visible = false
	action.visible = false

	if base_chain.size() > 0:
		var ordered_chain: Array[Dictionary] = base_chain.duplicate()
		ordered_chain.reverse()

		var root_type: ItemResource.Type = ordered_chain[0]["type"]
		add_chain_item(root_type)

		for step in ordered_chain:
			var base_type: ItemResource.Type = step["type"]
			var action_type: ItemResource.Process = step["process"]
			add_chain_action(action_type)

			var result_type: ItemResource.Type = ItemResource.PROCESSES[action_type][base_type]
			if result_type != type:
				add_chain_item(result_type)

	main.item = ItemResource.get_resource(type)

func clear_chain_nodes() -> void:
	for n in chain_nodes:
		n.queue_free()
	chain_nodes.clear()

func add_chain_item(item_type: ItemResource.Type) -> void:
	var item_node = base.duplicate() as CauldronItem
	item_node.visible = true
	item_node.item = ItemResource.get_resource(item_type)
	insert_before_main(item_node)

func add_chain_action(process_type: ItemResource.Process) -> void:
	var action_node = action.duplicate() as TextureRect
	action_node.visible = true
	action_node.texture = ItemResource.PROCESS_ICONS.get(process_type, null)
	insert_before_main(action_node)

func insert_before_main(node: Node) -> void:
	add_child(node)
	move_child(node, main.get_index())
	chain_nodes.append(node)
