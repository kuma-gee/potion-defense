extends Area3D

@export var float_speed := 0.8
@export var float_height := 0.05

@export_category("Crow")
@export var crow_move_speed := 0.5
@export var crow_path: PathFollow3D

@onready var visual: Node3D = $Root/Visual
@onready var root: Node3D = $Root
@onready var spawn_delay: Timer = $SpawnDelay
@onready var item_drop: ItemDrop = $ItemDrop
@onready var crow_sound: AudioStreamPlayer = $CrowSound

var time := 0.0
var recipe: ItemResource

func _ready() -> void:
	crow_sound.play()
	spawn_delay.timeout.connect(start)
	root.hide()
	
	item_drop.landed.connect(func():
		if has_overlapping_bodies():
			_pick_up()
		else:
			body_entered.connect(func(_b): _pick_up())
	)
	
func _pick_up():
	Events.pickup_recipe(recipe)
	queue_free()

func start():
	item_drop.start()
	root.show()

func _process(delta: float) -> void:
	if crow_path.progress_ratio < 1.0 and crow_path.visible:
		var value = crow_move_speed * delta
		if crow_path.progress_ratio + value > 1.0:
			crow_path.progress_ratio = 1.0
			crow_path.hide()
		else:
			crow_path.progress_ratio += value
	
	if not spawn_delay.is_stopped():
		return

	if not item_drop.process(delta):
		time += delta
		visual.position.y += sin(time * float_speed) * float_height * delta
