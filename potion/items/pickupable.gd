class_name Pickupable
extends RigidBody3D

signal picked_up(item_type: ItemResource.Type, by: Node3D)
signal hovered(actor)
signal unhovered(actor)
signal interacted(actor)
signal released(actor)

@export var item_type: ItemResource.Type = ItemResource.Type.RED_HERB
@export var label: Label3D
@export var min_hold_distance: float = 1.0
@export var max_hold_distance: float = 3.0
@export var hold_scroll_speed: float = 0.2
@export var follow_strength: float = 10.0
@export var drag_factor: float = 5.0
@export var rotation_damping: float = 8.0
@export var rotation_smoothness: float = 5.0
@export var break_force_threshold: float = 2.0

var hold_distance: float = 1.5
var item_node = null
var is_picked_up: bool = false
var holder: Node3D = null
var target_position: Vector3 = Vector3.ZERO

func _ready() -> void:
	if label:
		label.text = ItemResource.build_name(item_type)
		label.hide()
	
	_create_item_visual()
	hold_distance = clamp(hold_distance, min_hold_distance, max_hold_distance)

func _physics_process(delta: float) -> void:
	if is_picked_up and holder:
		_update_held_physics(delta)

		# Allow player to adjust hold_distance with scrollwheel
		_handle_scroll_input()
func _handle_scroll_input() -> void:
	# Only allow adjustment if held by a player
	if not holder:
		return

	if Input.is_action_just_pressed("scroll_up"):
		hold_distance = clamp(hold_distance + hold_scroll_speed, min_hold_distance, max_hold_distance)
	elif Input.is_action_just_pressed("scroll_down"):
		hold_distance = clamp(hold_distance - hold_scroll_speed, min_hold_distance, max_hold_distance)

	# Check for breaking on collision if this is a potion
	if item_node and ItemResource.is_potion(item_type):
		if _should_break():
			_break_potion()

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
		# Create a placeholder visual
		_create_placeholder_visual()

func _create_placeholder_visual() -> void:
	# Create a simple placeholder mesh if no scene is defined
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(0.3, 0.3, 0.3)
	mesh_instance.mesh = box_mesh
	
	# Create a simple material
	var material = StandardMaterial3D.new()
	material.albedo_color = _get_placeholder_color()
	mesh_instance.set_surface_override_material(0, material)
	
	add_child(mesh_instance)
	item_node = mesh_instance

func _get_placeholder_color() -> Color:
	# Different colors for different item types
	match item_type:
		ItemResource.Type.RED_HERB:
			return Color.RED
		ItemResource.Type.SULFUR:
			return Color.YELLOW
		ItemResource.Type.BLUE_CRYSTAL:
			return Color.BLUE
		ItemResource.Type.WATER:
			return Color.CYAN
		ItemResource.Type.GREEN_MOSS:
			return Color.GREEN
		ItemResource.Type.SPIDER_VENOM:
			return Color.DARK_MAGENTA
		ItemResource.Type.WHITE_FLOWER:
			return Color.WHITE
		ItemResource.Type.SPRING_WATER:
			return Color.LIGHT_BLUE
		ItemResource.Type.POTION_EMPTY:
			return Color.GRAY
		_:
			return Color.ORANGE

func _on_body_entered_pickup_area(body: Node3D) -> void:
	if is_picked_up:
		return
	
	# Check if the body has a method to hold items (like FPSPlayer)
	if body.has_method("pickup_item"):
		pickup_by(body)

func _on_interacted(actor: Node3D) -> void:
	# Called when player presses interact button while hovering
	if is_picked_up:
		return
	
	pickup_by(actor)

func hover(actor: Node3D) -> void:
	hovered.emit(actor)
	if label:
		label.show()

func unhover(actor: Node3D) -> void:
	unhovered.emit(actor)
	if label:
		label.hide()

func interact(actor: Node3D) -> void:
	if label:
		label.hide()
	interacted.emit(actor)
	_on_interacted(actor)

func release(actor: Node3D) -> void:
	released.emit(actor)

func pickup_by(actor: Node3D) -> void:
	if is_picked_up:
		return
	
	is_picked_up = true
	holder = actor
	
	# Disable collision with the holder
	if actor is CharacterBody3D or actor is RigidBody3D:
		add_collision_exception_with(actor)
	
	# Hide label while held
	if label:
		label.hide()
	
	# Emit signal with item type and actor
	picked_up.emit(item_type, actor)
	
	# Notify actor if they have the method
	if actor.has_method("pickup_item"):
		actor.pickup_item(self)

func drop() -> void:
	if not is_picked_up:
		return
	
	is_picked_up = false
	
	# Re-enable collision
	if holder and (holder is CharacterBody3D or holder is RigidBody3D):
		remove_collision_exception_with(holder)
	
	# Show label again
	if label:
		label.show()
	
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
	
	# Calculate force to pull item to target position
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
		
		# Update the label text
		if label:
			label.text = ItemResource.build_name(item_type)

func _should_break() -> bool:
	if not _is_colliding():
		return false
	
	var l = linear_velocity.length()
	var threshold = break_force_threshold
	if item_type == ItemResource.Type.POTION_EMPTY:
		threshold *= 2
	
	var potion = item_node as Potion
	if potion and potion.is_hitting_enemy():
		return true
	
	return l > threshold

func _is_colliding() -> bool:
	# Use Godot's built-in collision detection
	return get_contact_count() > 0

func _break_potion() -> void:
	if item_node and item_node is Potion:
		var potion := item_node as Potion
		potion.on_hit()

	queue_free()
