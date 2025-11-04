class_name ItemScreenshotCamera
extends Node3D

const SAVE_PATH = "res://potion/items/images/"
const ITEMS_TO_CAPTURE = [
	ItemResource.Type.RED_HERB,
	ItemResource.Type.SULFUR,
	ItemResource.Type.BLUE_CRYSTAL,
	ItemResource.Type.WATER,
	ItemResource.Type.GREEN_MOSS,
	ItemResource.Type.SPIDER_VENOM,
	ItemResource.Type.WHITE_FLOWER,
	ItemResource.Type.SPRING_WATER,
	ItemResource.Type.POTION_FIRE_BOMB,
	ItemResource.Type.POTION_ICE_SHARD,
	ItemResource.Type.POTION_POISON_CLOUD,
	ItemResource.Type.POTION_PARALYSIS,
]

@export var delay_between_captures: float = 0.2

@onready var camera: Camera3D = $SubViewport/Camera3D
@onready var spawn_point: Node3D = $SubViewport/SpawnPoint
@onready var sub_viewport: SubViewport = $SubViewport

var current_item_index: int = 0
var current_item: Node3D = null
var is_capturing: bool = false

func _ready() -> void:
	_ensure_screenshot_directory()
	_start_capturing()

func _ensure_screenshot_directory() -> void:
	var project_dir = ProjectSettings.globalize_path("user://")
	if DirAccess.make_dir_recursive_absolute(project_dir + "screenshots/items/") == OK:
		print("Ensured screenshot directory exists: %s" % SAVE_PATH)

func _start_capturing() -> void:
	if is_capturing:
		return
	
	is_capturing = true
	current_item_index = 0
	print("Starting item screenshot capture sequence...")
	_capture_next_item()

func _capture_next_item() -> void:
	if current_item_index >= ITEMS_TO_CAPTURE.size():
		print("Screenshot capture complete!")
		is_capturing = false
		get_tree().quit()
		return
	
	var item_type = ITEMS_TO_CAPTURE[current_item_index]
	current_item_index += 1
	
	_cleanup_current_item()
	_spawn_item(item_type)
	
	# Wait a frame for physics to settle and rendering to update
	await RenderingServer.frame_post_draw
	await get_tree().process_frame
	await get_tree().process_frame
	
	_take_screenshot(item_type)
	
	# Wait before capturing next item
	await get_tree().create_timer(delay_between_captures).timeout
	_capture_next_item()

func _spawn_item(item_type: ItemResource.Type) -> void:
	var scene = ItemResource.get_item_scene(item_type)
	if not scene:
		push_error("No scene found for item type: %s" % ItemResource.build_name(item_type))
		return
	
	current_item = scene.instantiate() as Node3D
	if current_item:
		if spawn_point:
			current_item.position = spawn_point.global_position
		else:
			current_item.position = Vector3.ZERO
		
		if ItemResource.is_potion(item_type):
			var potion := current_item as Potion
			potion.set_potion_type(item_type)
		
		sub_viewport.add_child(current_item)
		print("Spawned: %s" % ItemResource.build_name(item_type))

func _cleanup_current_item() -> void:
	if current_item:
		current_item.queue_free()
		current_item = null

func _take_screenshot(item_type: ItemResource.Type) -> void:
	var filename = "%s.png" % ItemResource.build_name(item_type).to_lower().replace(" ", "_")
	var filepath = SAVE_PATH + filename
	
	if camera:
		camera.current = true
	
	var image = sub_viewport.get_texture().get_image()
	if image:
		var error = image.save_png(filepath)
		if error == OK:
			print("Screenshot saved: %s" % filepath)
		else:
			push_error("Failed to save screenshot: %s (Error code: %d)" % [filepath, error])
	else:
		push_error("Failed to capture image for: %s" % ItemResource.build_name(item_type))
