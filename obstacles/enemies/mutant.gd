extends CharacterBody3D

@export var body: Node3D
@export var rotation_speed := 10.0

@onready var state_machine: StateMachine = $StateMachine
@onready var jump_area: JumpArea = $JumpArea
@onready var jump_attack: State = $StateMachine/JumpAttack
@onready var attack_timer: Timer = $AttackTimer

@onready var attacks := [jump_area]

func _ready() -> void:
	jump_area.jump_at.connect(func(pos: Vector3):
		jump_attack.target = pos
		state_machine.change_state(jump_attack)
	)

	attack_timer.timeout.connect(_attack)
	
func _attack():
	var available_attacks = attacks.filter(func(x): return x.can_attack())
	if available_attacks.is_empty(): return
	
	var attack  = available_attacks.pick_random()
	attack.attack()

func _physics_process(delta: float) -> void:
	rotate_body_to_velocity(delta)

func rotate_body_to_velocity(delta: float):
	var is_moving = velocity.length() > 0.01
	if is_moving and body:
		var velocity_direction = Vector3(velocity.x, 0, velocity.z).normalized()
		var target_transform = body.global_transform.looking_at(body.global_position + velocity_direction, Vector3.UP)
		body.global_transform = body.global_transform.interpolate_with(target_transform, delta * rotation_speed)
