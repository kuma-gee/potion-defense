class_name MapSelect
extends Node3D

@export var map_button: PackedScene
@export var map_container: Node3D
@export var BUTTON_SPACING: float = 6.0

@onready var player_join: PlayerJoin = $PlayerJoin

func _ready() -> void:
	get_tree().paused = false
	
	Events.player_has_joined.connect(spawn_player)
	for player_id in Events.players:
		spawn_player(player_id)

	var total_maps: int = Events.MAPS.size()
	var start_x: float = 0
	for i in range(total_maps):
		var node := map_button.instantiate() as MapButton
		var index: int = i
		node.res = load(Events.MAPS[index])
		node.is_disabled = index > Events.unlocked_map
		node.position = Vector3(start_x + (index * BUTTON_SPACING), 0.0, 0.0)
		node.next.connect(func(): SceneManager.change_to_game(index))
		map_container.add_child(node)

func spawn_player(id: String) -> void:
	player_join.setup_player(id)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed():
		Events.player_input_received(event)
