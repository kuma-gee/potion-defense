class_name Pickupable
extends RigidBody3D

signal picked_up(item_type: ItemResource.Type, by: Node3D)

@export var item_type: ItemResource.Type = ItemResource.Type.RED_HERB
@export var use_physics: bool = true
@export var min_hold_distance: float = 1.0
@export var max_hold_distance: float = 3.0
@export var hold_scroll_speed: float = 0.2
@export var follow_strength: float = 10.0
@export var drag_factor: float = 5.0
@export var rotation_damping: float = 8.0
@export var rotation_smoothness: float = 5.0
@export var break_force_threshold: float = 2.0
@export var pickup_time_break_threshold := 0.5

var hold_distance: float = 1.5
var item_node = null
var is_picked_up: bool = false
var holder: Node3D = null
var target_position: Vector3 = Vector3.ZERO
var pickup_time := 0.0
var invincible_time := 0.0
var shooting := false
var original_collision_layer: int = 0
var original_collision_mask: int = 0

func _ready() -> void:
	_create_item_visual()
	hold_distance = clamp(hold_distance, min_hold_distance, max_hold_distance)
	original_collision_layer = collision_layer
	original_collision_mask = collision_mask

func _physics_process(delta: float) -> void:
	if is_picked_up and holder:
		pickup_time += delta
		_update_held_physics(delta)

		# Allow player to adjust hold_distance with scrollwheel
		_handle_scroll_input()
	else:
		pickup_time = 0
		
	if invincible_time > 0:
		invincible_time -= delta
		print(invincible_time)
	
func _handle_scroll_input() -> void:
	if not holder: return

	if Input.is_action_just_pressed("scroll_up"):
		hold_distance = clamp(hold_distance + hold_scroll_speed, min_hold_distance, max_hold_distance)
	elif Input.is_action_just_pressed("scroll_down"):
		hold_distance = clamp(hold_distance - hold_scroll_speed, min_hold_distance, max_hold_distance)


func _create_item_visual() -> void:
	var item_scene = ItemResource.get_item_scene(item_type)
	if item_scene:
		var item_instance = item_scene.instantiate()
		add_child(item_instance)
		item_node = item_instance
		
		# If it's a potion, set the potion type
		if item_instance is Potion:
			var potion := item_instance as Potion
			potion.set_potion_type(item_type)
	else:
		push_warning("No scene defined for item type: %s" % ItemResource.build_name(item_type))

func interact(actor: Node3D) -> void:
	pickup_by(actor)
	
func pickup_by(actor: Node3D) -> void:
	if is_picked_up or shooting:
		return
	
	# shooting = false
	is_picked_up = true
	holder = actor
	
	# Disable collision layers
	collision_layer = 0
	collision_mask = 0
	
	# Disable collision with the holder
	if actor is CharacterBody3D or actor is RigidBody3D:
		add_collision_exception_with(actor)
	
	# Emit signal with item type and actor
	picked_up.emit(item_type, actor)
	
	# Notify actor if they have the method
	if actor.has_method("pickup_item"):
		actor.pickup_item(self)

func drop() -> void:
	if not is_picked_up:
		return
	
	is_picked_up = false
	
	# Re-enable collision layers
	collision_layer = original_collision_layer
	collision_mask = original_collision_mask
	
	# Re-enable collision 
	if holder and (holder is CharacterBody3D or holder is RigidBody3D):
		remove_collision_exception_with(holder)
	
	holder = null

func _update_held_physics(delta: float) -> void:
	# Calculate target position in front of holder
	var camera: Camera3D = null
	
	if holder.has_node("CameraRoot/Camera3D"):
		camera = holder.get_node("CameraRoot/Camera3D") as Camera3D
	elif holder.has_node("Camera3D"):
		camera = holder.get_node("Camera3D") as Camera3D
	
	if camera:
		target_position = camera.global_position + (-camera.global_transform.basis.z * hold_distance)
	else:
		target_position = holder.global_position + (-holder.global_transform.basis.z * hold_distance)
	
	if use_physics:
		# Physics-based movement
		var direction = target_position - global_position
		var distance = direction.length()
		
		# Apply force with drag
		var force = direction.normalized() * follow_strength * distance
		var drag = linear_velocity * drag_factor
		
		linear_velocity += (force - drag) * delta
		
		# Dampen rotation
		angular_velocity = angular_velocity.lerp(Vector3.ZERO, rotation_damping * delta)
		
		# Smoothly rotate to zero rotation
		rotation = rotation.lerp(Vector3.ZERO, rotation_smoothness * delta)
	else:
		# Direct snappy movement
		global_position = global_position.lerp(target_position, 20.0 * delta)
		global_rotation = global_rotation.lerp(Vector3.ZERO, 15.0 * delta)
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO

func shoot():
	shooting = true
	invincible_time = 0.1
	gravity_scale = 0.0

func can_pickup() -> bool:
	return not is_picked_up

# Call this to change the item type after instantiation
func set_item_type(new_type: ItemResource.Type) -> void:
	var old_type = item_type
	item_type = new_type
	
	if is_inside_tree():
		# Check if we can just update the existing potion visual
		var old_was_potion = ItemResource.is_potion(old_type)
		var new_is_potion = ItemResource.is_potion(new_type)
		
		if old_was_potion and new_is_potion and item_node:
			# Just update the existing potion's type
			var visual = item_node
			if visual is Potion:
				var potion := visual as Potion
				potion.set_potion_type(new_type)
		else:
			# Need to recreate the visual
			_create_item_visual()

func _should_break() -> bool:
	if is_picked_up and pickup_time < pickup_time_break_threshold:
		return false
	
	var threshold = break_force_threshold
	if item_type == ItemResource.Type.POTION_EMPTY:
		threshold *= 2
	
	var potion = item_node as Potion
	if potion.is_hitting_enemy():
		threshold /= 2
	
	var is_hitting = _is_colliding() or potion.is_hitting_enemy()
	var l = linear_velocity.length()
	
	return (l > threshold or shooting) and is_hitting

func _is_colliding() -> bool:
	return get_contact_count() > 0

func _break_potion() -> void:
	if item_node and item_node is Potion:
		var potion := item_node as Potion
		potion.on_hit()

	queue_free()

var was_colliding := false

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var contact_count: int = state.get_contact_count()
	
	if not ItemResource.is_potion(item_type) or invincible_time > 0: return

	if is_picked_up and pickup_time < pickup_time_break_threshold:
		return
	
	var threshold = get_break_threshold()
	#print("Pickup: %s, time: %s, speed: %s, collision: %s, hit: %s" % [is_picked_up, pickup_time, state.linear_velocity.length(), contact_count, item_node.is_hitting_enemy()])

	if shooting and item_node.is_hitting_enemy():
		_break_potion()
		return
	
	for i in range(contact_count):
		var impulse_vec := state.get_contact_impulse(i)
		if impulse_vec.length() > threshold:
			_break_potion()
			break
		
		if state.linear_velocity.length() > threshold:
			_break_potion()
			break

func get_break_threshold():
	var threshold = break_force_threshold
	if item_type == ItemResource.Type.POTION_EMPTY:
		threshold *= 2

	if item_node and item_node is Potion and (item_node as Potion).is_hitting_enemy():
		threshold /= 2

	return threshold;
