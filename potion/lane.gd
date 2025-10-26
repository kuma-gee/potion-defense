class_name Lane
extends RayInteractable

signal destroyed()

@export var potion_scene: PackedScene
@export var position_marker: Node3D
@export var spawn_distance := 50
@export var hurt_box: HurtBox

var potion: Throwable
var item = null:
	set(v):
		if item == null:
			potion = null
		
		item = v
		if item and not potion:
			potion = potion_scene.instantiate()
			potion.position = position_marker.global_position
			get_tree().current_scene.add_child(potion)

var enemies = []

func _ready() -> void:
	super()
	hovered.connect(func(a: FPSPlayer):
		label.text = "Put Potion" if _can_place_potion(a) else ""
		if item != null:
			label.text = "Shoot"
	)
	interacted.connect(func(a: FPSPlayer):
		if item != null:
			item = null
			fire()
		elif _can_place_potion(a):
			item = a.take_item()
	)
	hurt_box.died.connect(func():
		for e in enemies:
			if is_instance_valid(e):
				e.queue_free()
		enemies.clear()
		destroyed.emit()
		queue_free()
	)

func _can_place_potion(a: FPSPlayer) -> bool:
	return a.has_item() and ItemResource.is_potion(a.item) and item == null

func fire():
	if not potion:
		return
	
	var direction = (global_transform.basis.z).normalized()
	potion.throw(direction + Vector3.UP/3, 10.0)
	item = null

func get_spawn_position():
	return global_position + global_transform.basis.z.normalized() * spawn_distance
