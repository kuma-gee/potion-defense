class_name Pickupable
extends RigidBody3D

@export var item_pop: ItemPopup
@export var item_type: ItemResource.Type = ItemResource.Type.RED_HERB
@export var interactable: RayInteractable
# @export var use_physics: bool = true
# @export var min_hold_distance: float = 1.0
# @export var max_hold_distance: float = 3.0
# @export var hold_scroll_speed: float = 0.2
# @export var follow_strength: float = 10.0
# @export var drag_factor: float = 5.0
# @export var rotation_damping: float = 8.0
# @export var rotation_smoothness: float = 5.0

# var hold_distance: float = 1.5
var item_node = null
# var holder: Node3D = null
var target_position: Vector3 = Vector3.ZERO
# var pickup_time := 0.0
var invincible_time := 0.0
var shooting := false
# var original_collision_layer: int = 0
# var original_collision_mask: int = 0

const DEFAULT_ITEM = preload("uid://b83q7mgugu7sr")
const POTION_EMPTY = preload("uid://b36xk56a0wmoo")

func _ready() -> void:
	_create_item_visual()
	interactable.interacted.connect(pickup_by)
	
	# hold_distance = clamp(hold_distance, min_hold_distance, max_hold_distance)
	# original_collision_layer = collision_layer
	# original_collision_mask = collision_mask

func _physics_process(delta: float) -> void:
	if invincible_time > 0:
		invincible_time -= delta
	
# func _handle_scroll_input() -> void:
# 	if not holder: return

# 	if Input.is_action_just_pressed("scroll_up"):
# 		hold_distance = clamp(hold_distance + hold_scroll_speed, min_hold_distance, max_hold_distance)
# 	elif Input.is_action_just_pressed("scroll_down"):
# 		hold_distance = clamp(hold_distance - hold_scroll_speed, min_hold_distance, max_hold_distance)


func _create_item_visual() -> void:
	var item_scene = POTION_EMPTY if ItemResource.is_potion(item_type) else DEFAULT_ITEM
	var item = item_scene.instantiate()
	add_child(item)
	item_node = item
	item_pop.set_item(ItemResource.get_resource(item_type))
	
	if ItemResource.is_potion(item_type):
		item.set_potion_type(item_type)
		item.hit.connect(func(): queue_free())

# func interact(actor: Node3D) -> void:
# 	pickup_by(actor)
	
func pickup_by(actor: Node3D) -> void:
	if shooting:
		return
	
	if actor.has_method("pickup_item"):
		var res = ItemResource.get_resource(item_type)
		actor.pickup_item(res)
	
	queue_free()

# func drop() -> void:
# 	if not is_picked_up:
# 		return
	
# 	is_picked_up = false
	
# 	# Re-enable collision layers
# 	collision_layer = original_collision_layer
# 	collision_mask = original_collision_mask
	
# 	# Re-enable collision 
# 	if holder and (holder is CharacterBody3D or holder is RigidBody3D):
# 		remove_collision_exception_with(holder)
	
# 	holder = null

# func _update_held_physics(delta: float) -> void:
# 	# Calculate target position in front of holder
# 	var camera: Camera3D = null
	
# 	if holder.has_node("CameraRoot/Camera3D"):
# 		camera = holder.get_node("CameraRoot/Camera3D") as Camera3D
# 	elif holder.has_node("Camera3D"):
# 		camera = holder.get_node("Camera3D") as Camera3D
	
# 	if camera:
# 		target_position = camera.global_position + (-camera.global_transform.basis.z * hold_distance)
# 	else:
# 		target_position = holder.global_position + (-holder.global_transform.basis.z * hold_distance)
	
# 	if use_physics:
# 		# Physics-based movement
# 		var direction = target_position - global_position
# 		var distance = direction.length()
		
# 		# Apply force with drag
# 		var force = direction.normalized() * follow_strength * distance
# 		var drag = linear_velocity * drag_factor
		
# 		linear_velocity += (force - drag) * delta
		
# 		# Dampen rotation
# 		angular_velocity = angular_velocity.lerp(Vector3.ZERO, rotation_damping * delta)
		
# 		# Smoothly rotate to zero rotation
# 		rotation = rotation.lerp(Vector3.ZERO, rotation_smoothness * delta)
# 	else:
# 		# Direct snappy movement
# 		global_position = global_position.lerp(target_position, 20.0 * delta)
# 		global_rotation = global_rotation.lerp(Vector3.ZERO, 15.0 * delta)
# 		linear_velocity = Vector3.ZERO
# 		angular_velocity = Vector3.ZERO

func shoot(force: Vector3):
	shooting = true
	invincible_time = 0.1
	gravity_scale = 0.0
	apply_central_impulse(force)

# func can_pickup() -> bool:
# 	return not is_picked_up

func break_potion() -> void:
	if item_node and item_node is Potion:
		var potion := item_node as Potion
		potion.on_hit()

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if not ItemResource.is_potion(item_type) or invincible_time > 0: return

	if state.get_contact_count() > 0:
		break_potion()
