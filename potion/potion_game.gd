extends Node3D

@export var wave_manager: WaveManager
@export var wave_setup: WaveSetup
@export var items_node: Node3D
@export var unlocked_item: UnlockedItem

const NEW_ITEMS_FOR_WAVE = {
	1: ItemResource.Type.BLUE_CRYSTAL,
	3: ItemResource.Type.GREEN_MOSS,
}

var wave = 0
var unlocked_items := [ItemResource.Type.RED_HERB, ItemResource.Type.SULFUR]

func _ready() -> void:
	wave_manager.wave_completed.connect(_on_wave_completed)
	unlocked_item.closed.connect(func(): wave_setup.show_for_items(unlocked_items))
	wave_setup.selected_items.connect(_on_items_selected)
	
	_setup_items()
	start_game()

func _setup_items() -> void:
	var initial_items = []
	for item in items_node.get_children():
		if item is Chest:
			initial_items.append((item as Chest).item)
	
	wave_setup.setup_initial_items(initial_items)

func _on_items_selected(items: Array) -> void:
	for i in items_node.get_child_count():
		var child = items_node.get_child(i) as Chest
		if not child: continue

		child.item = items[i] if i < items.size() else -1
	
	start_game()

func start_game():
	wave_manager.begin_wave(wave)

func _on_wave_completed() -> void:
	wave += 1
	
	if wave in NEW_ITEMS_FOR_WAVE:
		var new_item = NEW_ITEMS_FOR_WAVE[wave]
		unlocked_items.append(new_item)
		unlocked_item.unlocked_item(new_item)
	else:
		wave_setup.show_for_items(unlocked_items)
