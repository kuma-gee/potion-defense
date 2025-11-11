class_name WaveSetup
extends Control

signal selected_items(items: Array)

@export var item_select_grid: Control
@export var selected_items_container: Control
@export var item_button_scene: PackedScene
@export var ingredient_label: Label
@export var finish_button: Button

var items := []
var ingredient_resources: Array[ItemResource] = []

func _ready() -> void:
	hide()

	# Load all ingredient resources from the resources folder
	var dir = DirAccess.open("res://potion/items/resources/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var resource_path = "res://potion/items/resources/" + file_name
			if ResourceLoader.exists(resource_path) and not file_name.begins_with("potion"):
				var resource = load(resource_path) as ItemResource
				if resource:
					ingredient_resources.append(resource)
					var item_button = _create_item_button(resource)
					item_button.pressed.connect(func():
						_on_item_button_pressed(resource)
					)
					item_select_grid.add_child(item_button)
			file_name = dir.get_next()
	
	finish_button.pressed.connect(func():
		selected_items.emit(items)
		hide()
	)

func show_for_items(unlocked: Array):
	for item in item_select_grid.get_children():
		item.locked = not item.res.type in unlocked
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_item_button_pressed(item: ItemResource) -> void:
	if items.size() >= selected_items_container.get_child_count(): #or item_type in items:
		return

	for c in selected_items_container.get_children():
		if c.res == null:
			c.res = item
			items.append(item)
			break
	
	_update_ingredient_label()

func _create_item_button(item: ItemResource) -> ItemButton:
	var item_button = item_button_scene.instantiate() as ItemButton
	item_button.res = item
	return item_button

func setup_initial_items(initial_items: Array, available_slots: int) -> void:
	items.clear()
	for c in selected_items_container.get_children():
		selected_items_container.queue_free()
	
	for i in available_slots:
		var item_button = _create_item_button(null)
		item_button.pressed.connect(func():
			items.erase(item_button.res)
			item_button.res = null
			_update_ingredient_label()
		)
		selected_items_container.add_child(item_button)
	
	for item in initial_items:
		_on_item_button_pressed(item)

func _update_ingredient_label():
	ingredient_label.text = "Ingredients %s/%s" % [items.size(), selected_items_container.get_child_count()]
	
