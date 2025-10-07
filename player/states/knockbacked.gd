extends State

@export var player: Player
@export var knockback_resistance = 5.0
@export var animation: PlayerAnimation
@export var frame_freeze: FrameFreeze

var knockback: Vector3

func enter():
	animation.hit()
	frame_freeze.freeze()

func physics_update(delta: float) -> void:
	player.velocity.x = knockback.x
	player.velocity.z = knockback.z
	knockback = knockback.lerp(Vector3.ZERO, delta * knockback_resistance)

	player.rotate_body_to_velocity(delta, knockback)

	if knockback.length() <= 0.01:
		state_machine.reset_state()
