extends Area3D

@export var drop_height := 3.0
@export var float_speed := 0.8
@export var float_height := 0.05

@onready var visual: Node3D = $Visual
@onready var spawn_delay: Timer = $SpawnDelay

var recipe: ItemResource
var time := 0.0
var landed := false

func _ready() -> void:
	spawn_delay.timeout.connect(start)
	hide()

func start():
	visual.position.y = drop_height
	show()

func land():
	visual.position.y = 0
	landed = true
	
	body_entered.connect(func(_b):
		Events.picked_up_recipe.emit(recipe)
		queue_free()
	)

func _process(delta: float) -> void:
	if not spawn_delay.is_stopped():
		return

	if not landed:
		if visual.position.y > 0.0:
			visual.position.y -= delta
		else:
			land()
	else:
		time += delta
		visual.position.y += sin(time * float_speed) * float_height * delta
