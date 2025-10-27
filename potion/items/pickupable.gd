class_name Pickupable
extends RigidBody3D

signal picked_up(item_type: ItemResource.Type, by: Node3D)

@export var item_type: ItemResource.Type = ItemResource.Type.RED_HERB
@export var pickup_radius: float = 1.5
@export var auto_pickup: bool = false

@onready var pickup_area: Area3D = $PickupArea
@onready var item_visual_root: Node3D = $ItemVisualRoot

var is_picked_up: bool = false

func _ready() -> void:
	# Setup pickup area if auto_pickup is enabled
	if auto_pickup and pickup_area:
		pickup_area.body_entered.connect(_on_body_entered_pickup_area)
	
	# Instantiate the visual representation of the item
	_create_item_visual()

func _create_item_visual() -> void:
	# Clear any existing visuals
	if item_visual_root:
		for child in item_visual_root.get_children():
			child.queue_free()
	else:
		# Create visual root if it doesn't exist
		item_visual_root = Node3D.new()
		item_visual_root.name = "ItemVisualRoot"
		add_child(item_visual_root)
	
	# Get the scene for this item type
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

func pickup_by(actor: Node3D) -> void:
	if is_picked_up:
		return
	
	is_picked_up = true
	
	# Emit signal with item type and actor
	picked_up.emit(item_type, actor)
	
	# Give item to actor if they have the method
	if actor.has_method("hold_item"):
		actor.hold_item(item_type)
	
	# Remove the pickup from the scene
	queue_free()

func can_pickup() -> bool:
	return not is_picked_up

# Call this to change the item type after instantiation
func set_item_type(new_type: ItemResource.Type) -> void:
	item_type = new_type
	if is_inside_tree():
		_create_item_visual()
