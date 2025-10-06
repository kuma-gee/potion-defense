extends State

@export var player: Player
@export var dodge_area: DodgeArea
@export var speed = 10.0
@export var duration = 0.1

@export_category("Dodge")
@export var dodge_time_scale: float = 0.5
@export var dodge_time_duration: float = 0.3

var time := 0.0
var dodging := false

func _ready() -> void:
	dodge_area.dodged.connect(_on_dodged)
	
func _on_dodged():
	dodging = true
	Engine.time_scale = dodge_time_scale
	await get_tree().create_timer(dodge_time_duration, false).timeout
	Engine.time_scale = 1.0
	dodging = false

func enter() -> void:
	var dir = player.get_forward_input()
	player.velocity = dir * speed
	time = 0
	dodge_area.dodge()

func update(delta: float) -> void:
	time += delta
	if time >= duration:
		state_machine.reset_state()
