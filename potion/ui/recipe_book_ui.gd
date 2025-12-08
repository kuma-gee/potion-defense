class_name RecipeBookUI
extends Control

@export var item_scene: PackedScene
@export var ingredient_container: Control
@export var potion_item: CauldronItem
@export var page_label: Label

var pages = []
var current_page := 0:
	set(v):
		current_page = clamp(v, 0, max(pages.size() - 1, 0))
		page_label.text = "Page %d/%d" % [current_page + 1, pages.size()]
		refresh_ingredients()

func update_unlocked(recipes: Array[ItemResource.Type]) -> void:
	pages = []
	for r in recipes:
		if r in ItemResource.RECIPIES.keys():
			pages.append(r)

	pages.sort()
	current_page = 0
	refresh_ingredients()

func refresh_ingredients() -> void:
	for child in ingredient_container.get_children():
		child.queue_free()

	if pages.is_empty(): return
	
	var potion = pages[current_page]
	for item in ItemResource.RECIPIES[potion]:
		var item_instance = item_scene.instantiate() as CauldronItem
		item_instance.item = ItemResource.get_resource(item)
		ingredient_container.add_child(item_instance)

	potion_item.item = ItemResource.get_resource(potion)

func _ready() -> void:
	hide()
	current_page = 0

func _unhandled_input(event: InputEvent) -> void:
	if not visible: return
	
	if event.is_action_pressed("recipes") or event.is_action_pressed("back"):
		close()
	elif event.is_action_pressed("ui_left") or event.is_action_pressed("move_left"):
		current_page -= 1
	elif event.is_action_pressed("ui_right") or event.is_action_pressed("move_right"):
		current_page += 1
	
	get_viewport().set_input_as_handled()

func pause() -> void:
	if pages.is_empty(): return
	
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func close():
	hide()
