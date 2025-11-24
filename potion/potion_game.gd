class_name PotionGame
extends Node3D

@export var max_wave := 4
@export var wave_label: Label

@export var initial_items: Array[ItemResource] = []
@export var map_root: Node3D
@export var map_scene: PackedScene
@export var player_root: Node3D

@export var wave_manager: WaveManager
@export var wave_setup: WaveSetup
@export var unlocked_item: UnlockedItem
#@export var pause: Pause
@export var recipe_ui: RecipeBookUI

const NEW_ITEMS_FOR_WAVE = {
	#1: ItemResource.Type.ICE_SHARD,
	#3: ItemResource.Type.SPIDER_VENOM,
}

var map: Map
var unlocked_items := [ItemResource.Type.RED_HERB, ItemResource.Type.CHARCOAL]

var wave = 0:
	set(v):
		wave = v
		wave_label.text = "Wave %s / %s" % [wave, max_wave]

func _ready() -> void:
	wave_manager.wave_completed.connect(_on_wave_completed)
	#unlocked_item.closed.connect(func(): wave_setup.show_for_items(unlocked_items))
	#wave_setup.selected_items.connect(_on_items_selected)
	_setup_map()

func _unhandled_input(event: InputEvent) -> void:
	if wave_manager.is_wave_active:
		if event.is_action_pressed("pause"):
			recipe_ui.pause()

func _setup_items() -> void:
	#wave_setup.setup_initial_items(initial_items, map.items.get_child_count())
	_on_items_selected(initial_items)

func _setup_map():
	map = map_scene.instantiate() as Map
	map_root.add_child(map)
	wave_manager.setup(map.lanes)
	#if map.recipe_book:
		#map.recipe_book.interacted.connect(func(_a): recipe_ui.grab_focus())
	_setup_items()

func _on_items_selected(items: Array) -> void:
	#for i in map.items.get_child_count():
		#var child = map.items.get_child(i) as Chest
		#if not child: continue
#
		#child.item = items[i] if i < items.size() else null
	
	start_game()

func start_game():
	wave_manager.begin_wave(wave)
	
	#for node in get_tree().get_nodes_in_group("resetable"):
		#if node.has_method("start"):
			#node.start()

func _on_wave_completed() -> void:
	wave += 1
	await get_tree().create_timer(2.0).timeout
	start_game()
	#_reset_objects()
	#get_viewport().gui_release_focus()
	
	#if wave in NEW_ITEMS_FOR_WAVE:
		#var new_item = NEW_ITEMS_FOR_WAVE[wave]
		#unlocked_items.append(new_item)
		#unlocked_item.unlocked_item(new_item)
	#else:
		#wave_setup.show_for_items(unlocked_items)

func _reset_objects(restore = false):
	for node in get_tree().get_nodes_in_group("resetable"):
		if node.has_method("reset"):
			node.reset(restore)

func stop_wave():
	wave_manager.stop_wave()
	_reset_objects(true)
	wave_setup.show_for_items(unlocked_items)
