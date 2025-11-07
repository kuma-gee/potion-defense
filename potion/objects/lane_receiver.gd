class_name LaneReceiver
extends RayInteractable

signal destroyed()

const PICKUPABLE = preload("uid://bryjvapfcc2mh")

@export var spawn_distance := 50
@export var hurt_box: HurtBox
@export var aiming_system: TrajectoryAimingSystem
@export var shoot_force: float = 20.0

var wave_start_health := 0
var potion: Pickupable = null
var potion_type: int = -1
var enemies = []

func _ready() -> void:
	super()
	
	if hurt_box:
		hurt_box.died.connect(func():
			for e in enemies:
				if is_instance_valid(e):
					e.queue_free()
			enemies.clear()
			destroyed.emit()
			hide()
		)
	
	interacted.connect(handle_interacted)
	hovered.connect(handle_hovered)

func start():
	wave_start_health = hurt_box.health

func is_destroyed():
	return hurt_box.is_dead()

func handle_hovered(_actor: Node) -> void:
	if _actor is FPSPlayer:
		var player := _actor as FPSPlayer
		if _can_place_potion(player):
			label.text = "Put Potion"
		elif potion_type >= 0:
			label.text = "Shoot"
		else:
			label.text = ""

func handle_interacted(actor: FPSPlayer) -> void:
	if not actor: return

	if _can_place_potion(actor):
		potion_type = actor.release_item()
		potion = PICKUPABLE.instantiate()
		potion.item_type = potion_type as ItemResource.Type
		potion.position = global_position + Vector3.UP
		get_tree().current_scene.add_child(potion)
	elif potion_type >= 0:
		_shoot_potion_straight(actor)

func _shoot_potion_straight(_actor: Node) -> void:
	if potion_type < 0 or not potion:
		return
	
	var shoot_direction := global_transform.basis.z
	potion.shoot(shoot_direction.normalized() * shoot_force)
	potion_type = -1

func _can_place_potion(player: FPSPlayer) -> bool:
	if not player.has_item():
		return false
	
	var item_type = player.held_item_type as ItemResource.Type
	return ItemResource.is_potion(item_type) and potion_type < 0

func get_spawn_position() -> Vector3:
	return global_position + global_transform.basis.z.normalized() * spawn_distance

func reset(restore = false):
	if potion:
		potion.queue_free()
		potion = null
	potion_type = -1
	
	if restore:
		hurt_box.health = wave_start_health
