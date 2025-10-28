class_name Pickupable
extends RigidBody3D

signal picked_up(item_type: ItemResource.Type, by: Node3D)

@export var item_type: ItemResource.Type = ItemResource.Type.RED_HERB
@export var hold_distance: float = 2.0
@export var follow_strength: float = 10.0
@export var drag_factor: float = 5.0
@export var rotation_damping: float = 8.0

@onready var ray_interactable: RayInteractable = $RayInteractable
@onready var item_visual_root: Node3D = $ItemVisualRoot

var is_picked_up: bool = false
var holder: Node3D = null
var target_position: Vector3 = Vector3.ZERO

func _ready() -> void:
	if ray_interactable:
		if ray_interactable.label:
			ray_interactable.label.text = ItemResource.build_name(item_type)
		ray_interactable.interacted.connect(_on_interacted)
	
	_create_item_visual()

func _physics_process(delta: float) -> void:
	if is_picked_up and holder:
		_update_held_physics(delta)

func _create_item_visual() -> void:
	for child in item_visual_root.get_children():
		child.queue_free()
	
	var item_scene = ItemResource.get_item_scene(item_type)
	if item_scene:
		var item_instance = item_scene.instantiate()
		item_visual_root.add_child(item_instance)
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
	
	item_visual_root.add_child(mesh_instance)

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
	if body.has_method("hold_item"):
		pickup_by(body)

func _on_interacted(actor: Node3D) -> void:
	# Called when player presses interact button while hovering
	if is_picked_up:
		return
	
	pickup_by(actor)

func pickup_by(actor: Node3D) -> void:
	if is_picked_up:
		return
	
	is_picked_up = true
	holder = actor
	
	# Disable collision with the holder
	if actor is CharacterBody3D or actor is RigidBody3D:
		add_collision_exception_with(actor)
	
	# Disable ray interactable while held
	if ray_interactable:
		ray_interactable.monitoring = false
		if ray_interactable.label:
			ray_interactable.label.hide()
	
	# Emit signal with item type and actor
	picked_up.emit(item_type, actor)
	
	# Notify actor if they have the method
	if actor.has_method("hold_physical_item"):
		actor.hold_physical_item(self)

func drop() -> void:
	if not is_picked_up:
		return
	
	is_picked_up = false
	
	# Re-enable collision
	if holder and (holder is CharacterBody3D or holder is RigidBody3D):
		remove_collision_exception_with(holder)
	
	# Re-enable ray interactable
	if ray_interactable:
		ray_interactable.monitoring = true
		if ray_interactable.label:
			ray_interactable.label.show()
	
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

func can_pickup() -> bool:
	return not is_picked_up

# Call this to change the item type after instantiation
func set_item_type(new_type: ItemResource.Type) -> void:
	item_type = new_type
	if is_inside_tree():
		_create_item_visual()
		# Update the label text
		if ray_interactable and ray_interactable.label:
			ray_interactable.label.text = ItemResource.build_name(item_type)
