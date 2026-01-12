extends Control

@export var back_btn: BaseButton
@export var map_button: PackedScene
@export var map_container: Control

func _ready() -> void:
	get_tree().paused = false
	back_btn.pressed.connect(func(): SceneManager.change_to_start())
	
	for i in range(Events.MAPS.size()):
		var node = map_button.instantiate() as TextureButton
		node.res = load(Events.MAPS[i])
		node.is_disabled = i > Events.unlocked_map
		node.pressed.connect(func(): SceneManager.change_to_game(i))
		map_container.add_child(node)
