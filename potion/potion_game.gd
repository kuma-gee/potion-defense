class_name PotionGame
extends Node3D

@export var initial_items: Array[ItemResource] = []

@export var wave_manager: WaveManager
@export var wave_setup: WaveSetup
@export var items_node: Node3D
@export var unlocked_item: UnlockedItem
@export var pause: Pause

const NEW_ITEMS_FOR_WAVE = {
	2: ItemResource.Type.ICE_SHARD,
	4: ItemResource.Type.SPIDER_VENOM,
	6: ItemResource.Type.VULCANIC_ASH,
}

var wave = 0
var unlocked_items := [ItemResource.Type.RED_HERB, ItemResource.Type.CHARCOAL]

func _ready() -> void:
	wave_manager.wave_completed.connect(_on_wave_completed)
	unlocked_item.closed.connect(func(): wave_setup.show_for_items(unlocked_items))
	wave_setup.selected_items.connect(_on_items_selected)
	
	_setup_items()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and wave_manager.is_wave_active:
		pause.pause()

func _setup_items() -> void:
	wave_setup.setup_initial_items(initial_items, items_node.get_child_count())
	_on_items_selected(initial_items)

func _on_items_selected(items: Array) -> void:
	for i in items_node.get_child_count():
		var child = items_node.get_child(i) as Chest
		if not child: continue

		child.item = items[i] if i < items.size() else null
	
	start_game()

func start_game():
	wave_manager.begin_wave(wave)
	
	for node in get_tree().get_nodes_in_group("resetable"):
		if node.has_method("start"):
			node.start()

func _on_wave_completed() -> void:
	wave += 1
	_reset_objects()
	
	if wave in NEW_ITEMS_FOR_WAVE:
		var new_item = NEW_ITEMS_FOR_WAVE[wave]
		unlocked_items.append(new_item)
		unlocked_item.unlocked_item(new_item)
	else:
		wave_setup.show_for_items(unlocked_items)

func _reset_objects(restore = false):
	for node in get_tree().get_nodes_in_group("resetable"):
		if node.has_method("reset"):
			node.reset(restore)

func stop_wave():
	wave_manager.stop_wave()
	_reset_objects(true)
	wave_setup.show_for_items(unlocked_items)
