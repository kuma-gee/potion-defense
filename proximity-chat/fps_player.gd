class_name FPSPlayer
extends CharacterBody3D

@export var SPEED = 8.0
@export var mouse_sensitivity := Vector2(0.003, 0.002)

@export_category("Item Dropping")
@export var min_throw_force: float = 0.0
@export var max_throw_force: float = 10.0
@export var throw_charge_time: float = 1.0

@export var interact_ray: InteractRay
@export var camera: Camera3D
@export var camera_root: Node3D
@export var body: Node3D
@export var hold_position: Node3D

@export var item_placeholder: Node3D
@export var item_label: Label

@onready var player_input: PlayerInput = $PlayerInput
@onready var ground_spring_cast: GroundSpringCast = $GroundSpringCast

var drop_button_held: bool = false
var drop_charge_time: float = 0.0
var is_frozen: bool = false

var held_physical_item: Pickupable = null:
	set(v):
		held_physical_item = v
		#item_placeholder.visible = v != null
		item_label.text = "%s" % ItemResource.build_name(v.item_type) if v != null else ""

func get_interact_collision_point():
	if interact_ray.is_colliding():
		return interact_ray.get_collision_point()
	return interact_ray.global_position + interact_ray.target_position

func get_camera_point():
	return interact_ray.global_position

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _ready():
	# if Networking.has_network():
	# 	var is_authority = is_multiplayer_authority()
	# 	camera.current = is_authority
	# 	set_process_unhandled_input(is_authority)
	# 	set_physics_process(is_authority)
	# else:
	camera.current = true
	body.hide()
	
	# hand.released.connect(func(): camera.current = true)
	player_input.input_event.connect(func(event: InputEvent):
		if is_frozen:
			return
		
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			if event is InputEventMouseMotion:
				var sens = mouse_sensitivity
				rotate_y(-event.relative.x * sens.x)
				camera_root.rotate_x(-event.relative.y * sens.y)
				camera_root.rotation.x = clamp(camera_root.rotation.x, deg_to_rad(-70), deg_to_rad(70))
			elif event.is_action_pressed("ui_cancel"):
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_VISIBLE
			elif event.is_action_pressed("interact"):
				interact_ray.interact(self)
			elif event.is_action_released("interact"):
				interact_ray.release(self)
			elif event.is_action_pressed("drop_item"):
				start_drop_charge()
			elif event.is_action_released("drop_item"):
				release_drop_item()
	)

func _physics_process(delta):
	if is_frozen:
		velocity = Vector3.ZERO
		return
	
	# Update drop charge if button is held
	if drop_button_held:
		drop_charge_time = min(drop_charge_time + delta, throw_charge_time)
	
	var input_dir = player_input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var _speed = SPEED
	
	if ground_spring_cast.is_grounded():
		if direction:
			velocity.x = direction.x * _speed
			velocity.z = direction.z * _speed
		else:
			velocity.x = lerp(velocity.x, direction.x * _speed, delta * 15.0)
			velocity.z = lerp(velocity.z, direction.z * _speed, delta * 15.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * _speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * _speed, delta * 3.0)

	ground_spring_cast.apply_gravity(self, delta)
	move_and_slide()

func pickup_item(pickupable: Pickupable) -> void:
	if held_physical_item:
		held_physical_item.drop()
	
	held_physical_item = pickupable
	item_placeholder.visible = false

func has_item() -> bool:
	return held_physical_item != null

func release_physical_item():
	var item = held_physical_item
	if held_physical_item:
		held_physical_item.drop()
		held_physical_item = null
	return item

func freeze_player() -> void:
	is_frozen = true
	velocity = Vector3.ZERO

func unfreeze_player() -> void:
	is_frozen = false

func start_drop_charge() -> void:
	if held_physical_item == null:
		return
	
	drop_button_held = true
	drop_charge_time = 0.0

func release_drop_item() -> void:
	if not drop_button_held:
		return
	
	drop_button_held = false
	drop_item(drop_charge_time)
	drop_charge_time = 0.0

func get_throw_force(charge_time: float) -> float:
	# Calculate throw force based on how long the button was held
	var charge_ratio = clamp(charge_time / throw_charge_time, 0.0, 1.0)
	return lerp(min_throw_force, max_throw_force, charge_ratio)

func get_charge_percentage() -> float:
	# Returns the current charge percentage (0.0 to 1.0)
	if not drop_button_held:
		return 0.0
	return clamp(drop_charge_time / throw_charge_time, 0.0, 1.0)

func drop_item(charge_time: float = 0.0) -> void:
	if held_physical_item == null:
		return
	
	var throw_force = get_throw_force(charge_time)
	var throw_direction = -global_transform.basis.z + Vector3.UP * 0.3
	
	held_physical_item.drop()
	held_physical_item.linear_velocity = throw_direction.normalized() * throw_force
	print("Threw physical item: %s (throw force: %.1f)" % [ItemResource.build_name(held_physical_item.item_type), throw_force])
	held_physical_item = null
