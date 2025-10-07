extends State

@export var player: Player
@export var dash_state: State
@export var knockback_state: State

@export var default_speed = 3.0
@export var sprint_speed = 5.0
@export var acceleration = 8.0
@export var deceleration = 12.0
@export var dodge_stamina := 20

func _ready() -> void:
	player.knocked_back.connect(func(f):
		knockback_state.knockback = f
		state_machine.change_state(knockback_state)
	)

func physics_update(delta: float) -> void:
	var direction = player.get_forward_input()
	var speed = default_speed
	if Input.is_action_pressed("sprint") and player.stamina.has_stamina():
		speed = sprint_speed
	
	if player.is_grounded():
		if direction:
			player.velocity.x = lerp(player.velocity.x, direction.x * speed, delta * acceleration)
			player.velocity.z = lerp(player.velocity.z, direction.z * speed, delta * acceleration)
		else:
			player.velocity.x = lerp(player.velocity.x, 0.0, delta * deceleration)
			player.velocity.z = lerp(player.velocity.z, 0.0, delta * deceleration)
	else:
		if direction:
			player.velocity.x = lerp(player.velocity.x, direction.x * speed, delta * acceleration * 0.2)
			player.velocity.z = lerp(player.velocity.z, direction.z * speed, delta * acceleration * 0.2)
		else:
			player.velocity.x = lerp(player.velocity.x, 0.0, delta * deceleration * 0.1)
			player.velocity.z = lerp(player.velocity.z, 0.0, delta * deceleration * 0.1)

	if Input.is_action_just_pressed("dodge") and direction.length() > 0.01 and player.stamina.use_stamina(dodge_stamina):
		state_machine.change_state(dash_state)

	player.rotate_body_to_velocity(delta, direction)
