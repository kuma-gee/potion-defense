class_name WaveSetup
extends Control

signal selected_items(items: Array)

@export var item_select_grid: Control
@export var selected_items_container: Control
@export var item_button_scene: PackedScene
@export var finish_button: Button

var items := []
var limit := 0

func _ready() -> void:
	hide()

	for item in ItemResource.Type.values():
		var item_button = _create_item_button(item)
		item_button.pressed.connect(func(t = item):
			_on_item_button_pressed(t)
		)
		item_select_grid.add_child(item_button)
	
	finish_button.pressed.connect(func(): selected_items.emit(items))

func _on_item_button_pressed(item_type: ItemResource.Type) -> void:
	if limit > 0 and items.size() >= limit:
		return

	items.append(item_type)
	var item_button = _create_item_button(item_type)
	item_button.pressed.connect(func():
		items.erase(item_type)
		item_button.queue_free()
	)
	selected_items_container.add_child(item_button)
	
func _create_item_button(item_type: ItemResource.Type) -> ItemButton:
	var item_button = item_button_scene.instantiate() as ItemButton
	item_button.type = item_type
	return item_button

func setup_initial_items(initial_items: Array) -> void:
	items.clear()
	selected_items_container.clear_children()
	limit = initial_items.size()
	
	for item in initial_items:
		_on_item_button_pressed(item)
