class_name WaveSetup
extends Control

signal selected_items(items: Array)

@export var item_select_grid: Control
@export var selected_items_container: Control
@export var item_button_scene: PackedScene
@export var ingredient_label: Label
@export var finish_button: Button

var items := []
var limit := 0

func _ready() -> void:
	hide()

	for item in ItemResource.Type.values():
		if ItemResource.is_potion(item):
			continue

		var item_button = _create_item_button(item)
		item_button.pressed.connect(func(t = item):
			_on_item_button_pressed(t)
		)
		item_select_grid.add_child(item_button)
	
	finish_button.pressed.connect(func():
		selected_items.emit(items)
		hide()
	)

func show_for_items(unlocked: Array):
	for item in item_select_grid.get_children():
		item.locked = not item.type in unlocked
	show()

func _on_item_button_pressed(item_type: ItemResource.Type) -> void:
	if items.size() >= limit or item_type in items:
		return

	items.append(item_type)
	var item_button = _create_item_button(item_type)
	item_button.pressed.connect(func():
		items.erase(item_type)
		item_button.queue_free()
		_update_ingredient_label()
	)
	selected_items_container.add_child(item_button)
	_update_ingredient_label()
	
func _create_item_button(item_type: ItemResource.Type) -> ItemButton:
	var item_button = item_button_scene.instantiate() as ItemButton
	item_button.type = item_type
	return item_button

func setup_initial_items(initial_items: Array) -> void:
	items.clear()
	for c in selected_items_container.get_children():
		selected_items_container.queue_free()
	
	limit = initial_items.size()
	for item in initial_items:
		_on_item_button_pressed(item)

func _update_ingredient_label():
	ingredient_label.text = "Ingredients %s/%s" % [items.size(), limit]
	
