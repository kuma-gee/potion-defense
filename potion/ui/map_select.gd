class_name MapSelect
extends Node3D

@export var map_button: PackedScene
@export var map_container: Node3D
@export var BUTTON_SPACING: float = 6.0
@export var dash_ui: Control
@export var right_wall: Node3D
@export var camera_speed: float = 6.0
@export var right_wall_offset: float = 12.0

@onready var player_join: PlayerJoin = $PlayerJoin
@onready var camera_3d: Camera3D = $Camera3D

var max_pos := Vector3.ZERO
var min_pos := Vector3.ZERO

func _ready() -> void:
	get_tree().paused = false
	
	Events.player_has_joined.connect(spawn_player)
	dash_ui.visible = not Events.players.is_empty()
	
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
		max_pos = node.global_position

	if right_wall:
		right_wall.global_position.x = max_pos.x + right_wall_offset

func spawn_player(id: String) -> void:
	player_join.setup_player(id)
	dash_ui.show()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed():
		Events.player_input_received(event)

func _process(delta: float) -> void:
	var players: Array[Node] = player_join.player_root.get_children()
	if players.is_empty():
		return

	var min_x: float = INF
	var max_x: float = -INF
	for player_node: Node in players:
		var player: Node3D = player_node as Node3D
		if not player:
			continue
		
		var player_x: float = player.global_position.x
		min_x = min(min_x, player_x)
		max_x = max(max_x, player_x)

	if min_x == INF:
		return

	var target_x: float = clamp((min_x + max_x) * 0.5, min_pos.x, max_pos.x)
	camera_3d.global_position.x = move_toward(camera_3d.global_position.x, target_x, camera_speed * delta)
