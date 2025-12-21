class_name FPSPlayer
extends Character

const PICKUPABLE_SCENE = preload("res://potion/items/pickupable.tscn")

signal died()

@export var dash_force = 10.0
@export var dash_cooldown = 0.5
@export var push_force = 2.0
@export var mouse_sensitivity := Vector2(0.003, 0.002)

@export var anim: PlayerAnim
@export var body: Node3D
@export var walk_vfx: GPUParticles3D
@export var dash_vfx: GPUParticles3D

@export var colors: Array[Color] = []
@export var color_ring: ColorRect

@export_category("Death")
@export var death_time := 6.0
@export var revive_assist_increase := 2.0
@export var revive_progress: Range
@export var revive_interact: RayInteractable

@export_category("Top down")
@export var hand: Area3D
@export var item_texture: ItemPopup
@export var catch_area: Area3D

@export_category("Visuals")
@export var wand_texture: TextureRect

@export_category("Throw")
@export var throw_dir_sprite: Sprite3D
@export var throw_dir_min_scale = 0.3
@export var throw_dir_max_scale = 0.7
@export var throw_charge_time: float = 1.0
@export var min_throw_force: float = 5.0
@export var max_throw_force: float = 20.0

@onready var player_input: PlayerInput = $PlayerInput
@onready var ground_spring_cast: GroundSpringCast = $GroundSpringCast
@onready var icon: Sprite3D = $Icon
@onready var wand_ability: WandAbility = $WandAbility
@onready var shield: Shield = $Shield
@onready var dash_sound: RandomizedLoopSfx = $DashSound

var death_timer := 0.0:
	set(v):
		death_timer = v
		revive_progress.value = v

var input_id := ""
var player_num := 0
var is_frozen: bool = false
var dash_cooldown_timer: float = 0.0
var dash_duration: float = 0.0

var reviving_player: FPSPlayer:
	set(v):
		reviving_player = v
		icon.visible = not v

var throw_button_held: bool = false:
	set(v):
		throw_button_held = v
		throw_dir_sprite.visible = v
	
var current_throw_force: float = 0.0:
	set(v):
		current_throw_force = v
		var t = (current_throw_force) / (max_throw_force - min_throw_force)
		throw_dir_sprite.scale.x = lerp(throw_dir_min_scale, throw_dir_max_scale, t)

var mouse_position: Vector2 = Vector2.ZERO
var equipped_wand: WandResource = null:
	set(v):
		equipped_wand = v
		shield.visible = is_shield()
		wand_texture.texture = equipped_wand.icon if equipped_wand else null

var equipped_equipment: EquipmentResource = null

var item_count := 0:
	set(v):
		item_count = v
		item_texture.set_count(v)
var held_item_type: ItemResource = null:
	set(v):
		held_item_type = v
		item_texture.set_item(v)

func _get_mouse_world_position() -> Vector3:
	var current_camera = get_viewport().get_camera_3d()
	if not current_camera:
		return global_position + Vector3.FORWARD
	
	var ray_origin = current_camera.project_ray_origin(mouse_position)
	var ray_normal = current_camera.project_ray_normal(mouse_position)
	
	var plane = Plane(Vector3.UP, global_position.y)
	var intersection = plane.intersects_ray(ray_origin, ray_normal)
	
	if intersection:
		return intersection
	return global_position + Vector3.FORWARD

func _ready():
	super()
	equipped_wand = null
	equipped_equipment = null
	player_input.set_for_id(input_id)
	reset()

	color_ring.color = colors[player_num % colors.size()]
	throw_dir_sprite.modulate = colors[player_num % colors.size()]
	revive_progress.max_value = death_time
	
	icon.hide()
	revive_progress.hide()
	revive_interact.hovered.connect(func(_a):
		if hurt_box.is_dead():
			icon.show()
	)
	revive_interact.unhovered.connect(func(_a): icon.hide())
	revive_interact.interacted.connect(func(a):
		if hurt_box.is_dead():
			reviving_player = a
	)
	revive_interact.released.connect(func(a):
		if a == reviving_player:
			reviving_player = null
	)
	catch_area.body_entered.connect(_on_catch_area_body_entered)

	revive_interact.monitorable = false
	hurt_box.died.connect(func():
		reset()
		revive_progress.show()
		revive_interact.set_deferred("monitorable", true)
		anim.died()
	)

	wand_ability.start_charge.connect(func(): freeze_player())
	wand_ability.finish_charge.connect(func(): unfreeze_player())
	wand_ability.cooldown_finished.connect(func():
		if is_shield():
			shield.restore_shield()
	)
	shield.broken.connect(func():
		deactivate_shield()
		wand_ability.start_cooldown()
	)
	
	player_input.input_event.connect(func(event: InputEvent):
		if hurt_box.is_dead(): return
		
		if event is InputEventMouseMotion:
			mouse_position = event.position
		if event.is_action_pressed("interact"):
			hand.interact(self)
		elif event.is_action_released("interact"):
			hand.release(self)
		elif event.is_action_pressed("action"):
			if has_item():
				if is_holding_potion():
					throw_button_held = true
			else:
				hand.action(self)
		elif event.is_action_released("action"):
			if has_item() and throw_button_held:
				throw_item()
				throw_button_held = false
			else:
				hand.action_released(self)
		elif event.is_action_pressed("back") and throw_button_held:
			throw_button_held = false
			current_throw_force = 0.0
		elif event.is_action_pressed("wand_ability"):
			use_wand_ability()
		elif event.is_action_released("wand_ability"):
			release_wand_ability()
		elif event.is_action_pressed("dash"):
			dash_player()
			
		_debug_potion_spawn(event)
	)

func _debug_potion_spawn(event: InputEvent):
	if not event is InputEventKey or event.is_released(): return
	var key = event as InputEventKey
	
	if not key.shift_pressed: return
	
	if key.keycode == KEY_1:
		held_item_type = ItemResource.get_resource(ItemResource.Type.POTION_FIRE_BOMB)
		#equip_wand(preload("uid://co1p7scbvpyhc"))
	elif key.keycode == KEY_2:
		#held_item_type = ItemResource.get_resource(ItemResource.Type.POTION_BLIZZARD)
		equip_wand(preload("uid://dvcguwvkv4lg6"))
	elif key.keycode == KEY_3:
		#held_item_type = ItemResource.get_resource(ItemResource.Type.POTION_POISON_CLOUD)
		equip_wand(preload("uid://cotho06ohio7x"))

func get_input_direction() -> Vector3:
	var input_dir = player_input.get_vector("move_left", "move_right", "move_up", "move_down")
	var input = Vector3(input_dir.x, 0, input_dir.y).normalized()
	var direction = input
	return direction

func _physics_process(delta):
	if is_frozen or hurt_box.is_dead() or shield.is_active:
		velocity = Vector3.ZERO
		walk_vfx.emitting = false
		
		if hurt_box.is_dead():
			death_timer += delta * (1.0 if not reviving_player else revive_assist_increase)
			if death_timer >= death_time:
				death_timer = 0.0
				died.emit()
		walk_vfx.emitting = false
		return

	if apply_knockback(delta):
		walk_vfx.emitting = false
		return
	
	dash_cooldown_timer = max(0.0, dash_cooldown_timer - delta)
	dash_duration = max(0.0, dash_duration - delta)
	
	if throw_button_held and has_item():
		current_throw_force = min(current_throw_force + delta / throw_charge_time * (max_throw_force - min_throw_force), max_throw_force - min_throw_force)
		
		var mouse_world_pos = _get_mouse_world_position()
		var direction_to_mouse = (mouse_world_pos - global_position).normalized()
		if direction_to_mouse.length() > 0.1:
			body.look_at(body.global_position + direction_to_mouse, Vector3.UP)
	else:
		current_throw_force = 0.0
	
	var direction = get_input_direction()
	var _speed = get_actual_speed()
	walk_vfx.emitting = direction.length() > 0

	if dash_duration <= 0.0:
		if ground_spring_cast.is_grounded():
			if direction:
				velocity.x = direction.x * _speed
				velocity.z = direction.z * _speed
			else:
				velocity.x = lerp(velocity.x, direction.x * _speed, delta * 15.0)
				velocity.z = lerp(velocity.z, direction.z * _speed, delta * 15.0)
		else:
			velocity.x = lerp(velocity.x, direction.x * _speed, delta * 3.0)
			velocity.z = lerp(velocity.z, direction.z * _speed, delta * 3.0)

	if velocity.length() > 0.1:
		var target_direction = direction.normalized()
		var current_forward = -body.global_transform.basis.z
		var angle = current_forward.signed_angle_to(target_direction, Vector3.UP)
		body.rotate_y(angle * delta * 10.0)

	anim.update_move(direction)
	ground_spring_cast.apply_gravity(self, delta)
	move_and_slide()
	
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is FPSPlayer:
			var other_player = collider as FPSPlayer
			push_other_player(other_player)
			
			# Break potion only if dashing and facing each other
			#if dash_duration > 0.0:
				#if has_item():
					#break_potion()
				#else:
					#var my_forward = -body.global_transform.basis.z
					#var other_forward = -other_player.body.global_transform.basis.z
					#var facing_dot = my_forward.dot(other_forward)
					#
					#if facing_dot < -0.6 and other_player.has_item():
						#other_player.break_potion()
		#else:
			#if dash_duration > 0.0 and has_item():
				#break_potion()

func push_other_player(other_player: FPSPlayer) -> void:
	var push_direction = (other_player.global_position - global_position).normalized()

	if velocity.length() > 0 and other_player.velocity.length() < 0.1:
		other_player.velocity.x = push_direction.x * push_force
		other_player.velocity.z = push_direction.z * push_force

func pickup_item(item_type: ItemResource) -> bool:
	var glove_items = get_equipment_stat(EquipmentResource.Type.GATHERING_GLOVES)
	if has_item() and glove_items <= 0.0:
		return false
	
	if glove_items > 0 and held_item_type and (held_item_type.type != item_type.type or item_count >= glove_items):
		return false

	if held_item_type:
		item_count += 1
	else:
		item_count = 1

	held_item_type = item_type
	return true

func has_item() -> bool:
	return held_item_type != null

func is_holding_potion() -> bool:
	return has_item() and held_item_type.is_potion_item()

func release_item() -> ItemResource:
	var item = held_item_type

	item_count -= 1
	if item_count <= 0:
		held_item_type = null
		item_count = 0

	return item

func dash_player() -> void:
	if dash_cooldown_timer > 0.0:
		return
	
	var dash_dir = get_input_direction()
	if dash_dir.length() < 0.1:
		return
	
	body.look_at(body.global_position + dash_dir, Vector3.UP)

	velocity.x = dash_dir.x * dash_force
	velocity.z = dash_dir.z * dash_force
	dash_duration = 0.2
	dash_cooldown_timer = dash_cooldown
	dash_vfx.emitting = true
	dash_sound.start()

func throw_item() -> void:
	if not throw_button_held or not is_holding_potion():
		return
	
	var item = release_item()
	
	var throw_direction: Vector3
	var mouse_world_pos = _get_mouse_world_position()
	throw_direction = (mouse_world_pos - global_position).normalized()
	if throw_direction.length() < 0.1:
		throw_direction = -body.global_transform.basis.z
	
	var actual_force = min_throw_force + current_throw_force
	
	var pickupable: Pickupable = PICKUPABLE_SCENE.instantiate()
	pickupable.item_type = item.type
	
	var throw_position = hand.global_position + Vector3.UP * 0.5
	pickupable.position = throw_position
	
	get_tree().current_scene.add_child(pickupable)
	pickupable.apply_central_impulse(throw_direction.normalized() * actual_force)
	
	current_throw_force = 0.0
	throw_button_held = false

func break_potion() -> void:
	if not has_item() or not held_item_type.is_potion_item():
		return
	
	var broken_item = release_item()
	var node = Potion.spawn_effect(broken_item.type, global_position)
	if node:
		get_tree().current_scene.add_child(node)

func _on_catch_area_body_entered(caught_body: Node3D) -> void:
	if not throw_button_held or has_item() or not caught_body is Pickupable:
		return
	
	var pickupable = caught_body as Pickupable
	var item_resource = ItemResource.get_resource(pickupable.item_type)
	pickup_item(item_resource)
	pickupable.queue_free()

func freeze_player() -> void:
	is_frozen = true
	velocity = Vector3.ZERO
	anim.casting()

func unfreeze_player() -> void:
	is_frozen = false

func reset(_restore = false):
	hand.release(self)
	
	held_item_type = null
	is_frozen = false
	dash_duration = 0.0
	dash_cooldown_timer = 0.0
	throw_button_held = false
	current_throw_force = 0.0
	death_timer = 0.0
	if wand_ability:
		wand_ability.reset()

func effect_damage(amount: int, element: ElementalArea.Element) -> void:
	if has_immunity(): return
	super(amount, element)

func slow(type: String, factor: float) -> void:
	if has_immunity(): return
	super(type, factor)

#region Equipment/Wands
func equip_wand(wand: WandResource) -> void:
	equipped_wand = wand
	wand_ability.wand = wand
	wand_ability.reset()
	print("Equipped wand: %s" % WandResource.AbilityType.keys()[wand.ability_type])

func equip_equipment(equipment: EquipmentResource) -> void:
	equipped_equipment = equipment
	print("Equipped equipment: %s" % EquipmentResource.Type.keys()[equipment.equipment_type])

func is_shield():
	return equipped_wand and equipped_wand.ability_type == WandResource.AbilityType.SHIELD

func has_immunity():
	return get_equipment_stat(EquipmentResource.Type.IMMUNITY_CLOAK) > 0.0

func get_equipment_stat(type: EquipmentResource.Type, defaultValue = 0.0) -> float:
	if not equipped_equipment or equipped_equipment.equipment_type != type:
		return defaultValue
	return equipped_equipment.stat_value

func get_actual_speed(s = speed) -> float:
	var actual_speed = super.get_actual_speed(s)
	actual_speed *= 1 + get_equipment_stat(EquipmentResource.Type.SPEED_BOOTS)
	return actual_speed

func use_wand_ability() -> bool:
	if not equipped_wand or not wand_ability:
		return false
	
	wand_ability.activate()
	return true

func release_wand_ability() -> bool:
	if not equipped_wand or not wand_ability:
		return false
	
	wand_ability.deactivate()
	return true

func activate_shield():
	if hurt_box.is_dead(): return
	anim.shield_on()
	shield.activate_shield()

func deactivate_shield():
	if hurt_box.is_dead(): return
	anim.shield_off()
	shield.deactivate_shield()

func get_processing_speed() -> float:
	var base_speed = 1.0
	base_speed *= wand_ability.get_processing_speed()
	return base_speed
#endregion
