extends State

@export var player: Player
@export var dodge_area: DodgeArea
@export var speed = 10.0
@export var deaccel := 5.0
@export var animation: PlayerAnimation
@export var frame_freeze: FrameFreeze

var dodging := false
var dodge_dir: Vector3

func _ready() -> void:
	dodge_area.dodged.connect(_on_dodged)
	
func _on_dodged():
	dodging = true
	await frame_freeze.freeze()
	dodging = false

func enter() -> void:
	dodge_dir = player.get_forward_input()
	player.velocity = dodge_dir * speed
	dodge_area.dodge()
	animation.dodge()

func update(delta: float) -> void:
	player.velocity.x = lerp(player.velocity.x, 0.0, delta * deaccel)
	player.velocity.z = lerp(player.velocity.z, 0.0, delta * deaccel)
	player.rotate_body_to_velocity(delta, dodge_dir)

	if player.velocity.length() < 0.5:
		state_machine.reset_state()
