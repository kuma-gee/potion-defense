class_name LaneReceiver
extends ItemReceiver

signal potion_placed(potion_type: ItemResource.Type)
signal destroyed()

@export var spawn_distance := 50
@export var hurt_box: HurtBox
@export var aiming_system: TrajectoryAimingSystem
@export var shoot_force: float = 20.0

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

func handle_interacted(actor: FPSPlayer) -> void:
	if potion != null:
		_shoot_potion_straight(actor)
	elif actor and actor.has_item():
		var player := actor as FPSPlayer
		if _can_place_potion(player):
			var pickupable := player.held_physical_item
			if pickupable and can_accept_item(pickupable.item_type):
				handle_item_received(pickupable.item_type, pickupable)
				player.release_physical_item()

func _physics_process(delta: float) -> void:
	if potion:
		_snap_center(potion)

func _snap_center(pickupable: RigidBody3D):
	pickupable.global_position = global_position + Vector3.UP
	pickupable.global_rotation = Vector3.ZERO
	pickupable.linear_velocity = Vector3.ZERO
	pickupable.angular_velocity = Vector3.ZERO

func handle_released(_actor: Node) -> void:
	pass

func _on_force_changed(_force: float) -> void:
	if label and aiming_system:
		var force_percent := int(aiming_system.get_force_percentage() * 100)
		label.text = "Force: %d%% (Release to fire)" % force_percent

func _on_projectile_fired(force: float) -> void:
	if not potion:
		return
	
	var direction = aiming_system.get_throw_direction()
	potion.apply_central_impulse(direction.normalized() * force)
	potion.shoot()
	potion = null

func _on_aiming_cancelled() -> void:
	if label:
		label.text = "Shoot" if potion != null else ""

func _shoot_potion_straight(_actor: Node) -> void:
	if not potion:
		return
	
	var shoot_direction := global_transform.basis.z
	
	# if _actor is FPSPlayer:
	# 	var player := _actor as FPSPlayer
	# 	if player.camera:
	# 		shoot_direction = -player.camera.global_transform.basis.z
	
	potion.apply_central_impulse(shoot_direction.normalized() * shoot_force)
	potion.shoot()
	potion = null

func _can_place_potion(player: FPSPlayer) -> bool:
	if not player.has_item():
		return false
	
	if not player.held_physical_item:
		return false
	
	var item_type = player.held_physical_item.item_type
	return ItemResource.is_potion(item_type) and potion == null

func get_spawn_position() -> Vector3:
	return global_position + global_transform.basis.z.normalized() * spawn_distance
