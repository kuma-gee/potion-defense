class_name Chest
extends RayInteractable

@export var item := ItemResource.Type.RED_HERB
@export var spawn_offset := Vector3(0, 1.0, 0)
@export var spawn_impulse := Vector3(0, 3.0, 0)

var pickupable_scene := preload("res://potion/items/pickupable.tscn")

func _ready() -> void:
	super()
	label.text = ItemResource.build_name(item)
	interacted.connect(func(a: FPSPlayer):
		if a:
			_spawn_pickupable(a)
	)

func _spawn_pickupable(player: FPSPlayer) -> void:
	var pickupable_instance := pickupable_scene.instantiate() as Pickupable
	
	if pickupable_instance:
		pickupable_instance.item_type = item
		pickupable_instance.position = global_position + spawn_offset
		
		get_tree().current_scene.add_child(pickupable_instance)
		
		# Give it an upward impulse to pop out
		pickupable_instance.linear_velocity = spawn_impulse
		
		# Automatically pick it up
		pickupable_instance.pickup_by(player)
		
		print("Spawned pickupable from chest: %s" % ItemResource.build_name(item))
