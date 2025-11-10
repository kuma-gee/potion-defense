extends Control

signal game_started()

@export var game: PotionGame
@export var start_btn: BaseButton
@export var player_root: Node3D
@export var player_scene: PackedScene
@export var joined_label: Label

func _ready() -> void:
	get_tree().paused = true
	_update()
	
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	start_btn.pressed.connect(func():
		if player_root.get_child_count() == 0:
			return
		
		hide()
		get_tree().paused = false
		game_started.emit()
	)

func _unhandled_input(event: InputEvent) -> void:
	if visible:
		_spawn_player(event)

func _spawn_player(event: InputEvent) -> void:
	var id = PlayerInput.create_id(event)
	if player_root.has_node(id):
		if event.is_action_pressed("ready"):
			start_btn.pressed.emit()
		return

	var player = player_scene.instantiate() as FPSPlayer
	player.name = id
	player.player_num = player_root.get_child_count()
	player.position = game.map.spawn_points[player.player_num].global_position if player.player_num < game.map.spawn_points.size() else Vector3.ZERO
	player_root.add_child(player)
	_update()

func _update():
	joined_label.text = "Joined %s" % [player_root.get_child_count()]
