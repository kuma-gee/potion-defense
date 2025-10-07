extends State

@export var jump_speed: float = 15.0
@export var jump_height: float = 5.0
@export var gravity_multiplier: float = 1.5

@export var enemy: CharacterBody3D
@export var vfx_scene: PackedScene
@export var hit_area: HitBox
@export var camera_shake: CameraShake

@onready var land_recover: Timer = $LandRecover
@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_multiplier

var target: Vector3
var jump_velocity: Vector3
var is_jumping: bool = false
var has_landed: bool = false

func _ready() -> void:
	land_recover.timeout.connect(func(): state_machine.reset_state())

func enter() -> void:
	if not enemy:
		return
	
	is_jumping = true
	has_landed = false
	
	# Calculate jump trajectory to target
	var start_pos = enemy.global_position
	var horizontal_distance = Vector3(target.x - start_pos.x, 0, target.z - start_pos.z)
	var horizontal_speed = horizontal_distance.length() / calculate_jump_time()
	
	# Set horizontal velocity
	jump_velocity = horizontal_distance.normalized() * horizontal_speed
	
	# Set vertical velocity for desired jump height
	jump_velocity.y = sqrt(2 * gravity * jump_height)
	
	# Apply initial jump velocity
	enemy.velocity = jump_velocity

func physics_update(delta: float) -> void:
	if not enemy or not is_jumping:
		return
	
	# Apply gravity
	enemy.velocity.y -= gravity * delta
	
	# Move the enemy
	enemy.move_and_slide()
	
	# Check if landed
	if enemy.is_on_floor() and enemy.velocity.y <= 0 and not has_landed:
		has_landed = true
		on_landing()

func on_landing() -> void:
	_spawn_landing_vfx()
	hit_area.hit()
	camera_shake.shake()
	land_recover.start()

func _spawn_landing_vfx() -> void:
	if not vfx_scene: return

	var vfx_instance = vfx_scene.instantiate()
	get_tree().current_scene.add_child(vfx_instance)
	vfx_instance.global_position = enemy.global_position

func calculate_jump_time() -> float:
	# Calculate time to reach target based on jump height and gravity
	# Using kinematic equation: t = sqrt(2h/g) * 2 (up and down time)
	return sqrt(2 * jump_height / gravity) * 2
