class_name FPSPlayer
extends CharacterBody3D

const PICKUPABLE_SCENE = preload("res://potion/items/pickupable.tscn")

@export var SPEED = 3.0
@export var DASH_FORCE = 10.0
@export var DASH_COOLDOWN = 1.0
@export var PUSH_FORCE = 5.0
@export var throw_charge_time: float = 1.0
@export var min_throw_force: float = 5.0
@export var max_throw_force: float = 20.0
@export var mouse_sensitivity := Vector2(0.003, 0.002)

@export var camera: Camera3D
@export var camera_root: Node3D

@export var anim: AnimationTree
@export var body: Node3D
@export var walk_vfx: GPUParticles3D
@export var dash_vfx: GPUParticles3D

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
@export var catch_area: Area3D

@onready var player_input: PlayerInput = $PlayerInput
@onready var ground_spring_cast: GroundSpringCast = $GroundSpringCast

var player_num := 0
var is_frozen: bool = false
var dash_cooldown_timer: float = 0.0
var dash_duration: float = 0.0
var throw_button_held: bool = false
var current_throw_force: float = 0.0
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
	
	if catch_area:
		catch_area.body_entered.connect(_on_catch_area_body_entered)
	
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
				elif event.is_action_pressed("dash"):
					dash_player()
				elif event.is_action_pressed("drop_item"):
					throw_button_held = true
				elif event.is_action_released("drop_item"):
					throw_button_held = false
					if has_item():
						throw_item()
		else:
			if event.is_action_pressed("interact"):
				hand.interact(self)
			elif event.is_action_released("interact"):
				hand.release(self)
			elif event.is_action_pressed("dash"):
				dash_player()
			elif event.is_action_pressed("drop_item"):
				throw_button_held = true
			elif event.is_action_released("drop_item"):
				throw_button_held = false
				if has_item():
					throw_item()

	)

func _physics_process(delta):
	if is_frozen:
		velocity = Vector3.ZERO
		walk_vfx.emitting = false
		return
	
	dash_cooldown_timer = max(0.0, dash_cooldown_timer - delta)
	dash_duration = max(0.0, dash_duration - delta)
	
	if throw_button_held and has_item():
		current_throw_force = min(current_throw_force + delta / throw_charge_time * (max_throw_force - min_throw_force), max_throw_force - min_throw_force)
	else:
		current_throw_force = 0.0
	
	var input_dir = player_input.get_vector("move_left", "move_right", "move_up", "move_down")
	var input = Vector3(input_dir.x, 0, input_dir.y).normalized()
	var direction = (transform.basis * input) if camera.current else input.rotated(Vector3.UP, -PI/2)
	var _speed = SPEED
	walk_vfx.emitting = input_dir.length() > 0
	
	if dash_duration <= 0.0:
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
		var target_direction = direction.normalized()
		var current_forward = -body.global_transform.basis.z
		var angle = current_forward.signed_angle_to(target_direction, Vector3.UP)
		body.rotate_y(angle * delta * 10.0)
		#var pos = Vector3(body.global_position.x, 0, body.global_position.z)
		#body.basis = body.global_basis.looking_at(pos + direction)

	anim.set("parameters/Move/blend_amount", input_dir.length())
	ground_spring_cast.apply_gravity(self, delta)
	move_and_slide()
	
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is FPSPlayer:
			var other_player = collider as FPSPlayer
			var push_direction = (global_position - other_player.global_position).normalized()
			
			if input_dir.length() > 0 and other_player.velocity.length() < 0.1:
				other_player.velocity.x = push_direction.x * PUSH_FORCE
				other_player.velocity.z = push_direction.z * PUSH_FORCE

func pickup_item(item_type: ItemResource) -> void:
	held_item_type = item_type

func has_item() -> bool:
	return held_item_type != null

func release_item() -> ItemResource:
	var item = held_item_type
	held_item_type = null
	return item

func dash_player() -> void:
	if dash_cooldown_timer > 0.0:
		return
	
	var current_forward = -body.global_transform.basis.z.normalized()
	velocity.x = current_forward.x * DASH_FORCE
	velocity.z = current_forward.z * DASH_FORCE
	dash_duration = 0.2
	dash_cooldown_timer = DASH_COOLDOWN
	dash_vfx.emitting = true

func throw_item() -> void:
	if not has_item():
		return
	
	var item = release_item()
	var throw_direction = -body.global_transform.basis.z
	var actual_force = min_throw_force + current_throw_force
	
	var pickupable: Pickupable = PICKUPABLE_SCENE.instantiate()
	pickupable.item_type = item.type
	
	var throw_position = get_camera_point() if camera.current else hand.global_position + Vector3.UP * 0.5
	pickupable.global_position = throw_position
	
	get_tree().current_scene.add_child(pickupable)
	pickupable.shoot(throw_direction.normalized() * actual_force)
	
	current_throw_force = 0.0
	throw_button_held = false

func _on_catch_area_body_entered(caught_body: Node3D) -> void:
	if not throw_button_held or has_item() or not caught_body is Pickupable:
		return
	
	var pickupable = caught_body as Pickupable
	var item_resource = ItemResource.get_resource(pickupable.item_type)
	pickup_item(item_resource)
	pickupable.queue_free()

func freeze_player() -> void:
	is_frozen = true
	velocity = Vector3.ZERO

func unfreeze_player() -> void:
	is_frozen = false

func reset(_restore = false):
	held_item_type = null
	is_frozen = false
	dash_duration = 0.0
	dash_cooldown_timer = 0.0
	throw_button_held = false
	current_throw_force = 0.0
