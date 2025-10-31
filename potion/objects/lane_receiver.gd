class_name LaneReceiver
extends ItemReceiver

signal potion_placed(potion_type: ItemResource.Type)
signal destroyed()

@export var spawn_distance := 50
@export var hurt_box: HurtBox
@export var aiming_system: TrajectoryAimingSystem

var potion: Pickupable
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
			queue_free()
		)
	
	interacted.connect(handle_interacted)
	released.connect(handle_released)
	hovered.connect(handle_hovered)
	
	if aiming_system:
		aiming_system.force_changed.connect(_on_force_changed)
		aiming_system.projectile_fired.connect(_on_projectile_fired)
		aiming_system.aiming_cancelled.connect(_on_aiming_cancelled)
		

func can_accept_item(item_type: ItemResource.Type) -> bool:
	# Only accept potions (not empty, not ingredients)
	if not ItemResource.is_potion(item_type):
		return false
	
	# Don't accept if lane already has a potion
	if potion != null:
		return false
	
	return true

func handle_item_received(item_type: ItemResource.Type, pickupable: Pickupable) -> bool:
	potion = pickupable
	potion_placed.emit(pickupable.item_type)
	print("Placed potion on lane: %s" % ItemResource.build_name(pickupable.item_type))
	return false  # Don't remove the pickupable, we're using it

func handle_hovered(_actor: Node) -> void:
	if _actor is FPSPlayer:
		var player := _actor as FPSPlayer
		if _can_place_potion(player):
			label.text = "Put Potion"
		elif potion != null:
			label.text = "Shoot"
		else:
			label.text = ""

func handle_interacted(_actor: Node) -> void:
	if potion != null and aiming_system and not aiming_system.is_aiming:
		aiming_system.start_aiming(potion)

func handle_released(_actor: Node) -> void:
	if aiming_system:
		aiming_system.check_fire_on_release()

func _on_force_changed(_force: float) -> void:
	if label and aiming_system:
		var force_percent := int(aiming_system.get_force_percentage() * 100)
		label.text = "Force: %d%% (Release to fire)" % force_percent

func _on_projectile_fired(force: float) -> void:
	if not potion:
		return
	
	var direction = aiming_system.get_throw_direction()
	potion.apply_central_impulse(direction.normalized() * force)
	potion.shooting = true
	potion = null

func _on_aiming_cancelled() -> void:
	if label:
		label.text = "Shoot" if potion != null else ""

func _can_place_potion(player: FPSPlayer) -> bool:
	if not player.has_item():
		return false
	
	if not player.held_physical_item:
		return false
	
	var item_type = player.held_physical_item.item_type
	return ItemResource.is_potion(item_type) and potion == null

func get_spawn_position() -> Vector3:
	return global_position + global_transform.basis.z.normalized() * spawn_distance
