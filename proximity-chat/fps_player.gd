class_name FPSPlayer
extends CharacterBody3D

@export var SPEED = 8.0
@export var mouse_sensitivity := Vector2(0.003, 0.002)

@export var camera: Camera3D
@export var camera_root: Node3D

@export var anim: AnimationTree
@export var body: Node3D

@export var colors: Array[Color] = []
@export var color_ring: ColorRect

@export_category("Top down")
@export var hand: Area3D
@export var item_sprite: Sprite3D
@export var item_texture: TextureRect

@export_category("First person")
@export var interact_ray: InteractRay
@export var ui: CanvasLayer
@export var item_label: Label

@onready var player_input: PlayerInput = $PlayerInput
@onready var ground_spring_cast: GroundSpringCast = $GroundSpringCast

var player_num := 0
var is_frozen: bool = false
var held_item_type: ItemResource = null:
	set(v):
		held_item_type = v
		item_label.text = held_item_type.name if held_item_type else ""
		item_texture.texture = held_item_type.texture if held_item_type else null

func get_interact_collision_point():
	if interact_ray.is_colliding():
		return interact_ray.get_collision_point()
	return interact_ray.global_position + interact_ray.target_position

func get_camera_point():
	return interact_ray.global_position

#func _enter_tree():
	#set_multiplayer_authority(name.to_int())

func toggle_camera(value = not camera.current):
	camera.current = value
	body.visible = not camera.current
	item_sprite.visible = not camera.current
	ui.visible = camera.current

func _ready():
	player_input.set_for_id(name)
	color_ring.color = colors[player_num % colors.size()]
	held_item_type = null
	toggle_camera(false)
	
	player_input.input_event.connect(func(event: InputEvent):
		if event.is_action_pressed("switch_view"):
			toggle_camera()
		
		if camera.current:
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
		else:
			if event.is_action_pressed("interact"):
				hand.interact(self)
			elif event.is_action_released("interact"):
				hand.release(self)

	)

func _physics_process(delta):
	if is_frozen:
		velocity = Vector3.ZERO
		return
	
	# Update drop charge if button is held
	# if drop_button_held:
	# 	drop_charge_time = min(drop_charge_time + delta, throw_charge_time)
	
	var input_dir = player_input.get_vector("move_left", "move_right", "move_up", "move_down")
	var input = Vector3(input_dir.x, 0, input_dir.y).normalized()
	var direction = (transform.basis * input) if camera.current else input.rotated(Vector3.UP, -PI/2)
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

	if velocity.length() > 0.1:
		var target_direction = velocity.normalized()
		var current_forward = -body.global_transform.basis.z
		var angle = current_forward.signed_angle_to(target_direction, Vector3.UP)
		body.rotate_y(angle * delta * 10.0)

	anim.set("parameters/Move/blend_amount", input_dir.length())
	ground_spring_cast.apply_gravity(self, delta)
	move_and_slide()

func pickup_item(item_type: ItemResource) -> void:
	held_item_type = item_type

func has_item() -> bool:
	return held_item_type != null

func release_item() -> ItemResource:
	var item = held_item_type
	held_item_type = null
	return item

func freeze_player() -> void:
	is_frozen = true
	velocity = Vector3.ZERO

func unfreeze_player() -> void:
	is_frozen = false

func reset(_restore = false):
	held_item_type = null
	is_frozen = false

# func start_drop_charge() -> void:
# 	if not has_item():
# 		return
	
# 	drop_button_held = true
# 	drop_charge_time = 0.0

# func release_drop_item() -> void:
# 	if not drop_button_held:
# 		return
	
# 	drop_button_held = false
# 	drop_item(drop_charge_time)
# 	drop_charge_time = 0.0

# func get_throw_force(charge_time: float) -> float:
# 	# Calculate throw force based on how long the button was held
# 	var charge_ratio = clamp(charge_time / throw_charge_time, 0.0, 1.0)
# 	return lerp(min_throw_force, max_throw_force, charge_ratio)

# func get_charge_percentage() -> float:
# 	# Returns the current charge percentage (0.0 to 1.0)
# 	if not drop_button_held:
# 		return 0.0
# 	return clamp(drop_charge_time / throw_charge_time, 0.0, 1.0)

# func drop_item(_charge_time: float = 0.0) -> void:
# 	if not has_item():
# 		return
	
# 	print("Dropped item: %s" % ItemResource.build_name(held_item_type))
# 	held_item_type = -1
