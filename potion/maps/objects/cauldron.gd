class_name Cauldron
extends RayInteractable

signal died()

@export var item_container: Control
@export var item_scene: PackedScene

@export var success_anim: AnimationPlayer
@export var failure_anim: AnimationPlayer

@export_category("Mixing")
@export var progress: Range
@export var mix_icon: Texture2D
@export var mix_time_per_item := 4.0
@export var mix_progress_per_circle := 0.5
@export var overheat_decrease_per_circle := 1.5
@export var potion_size := 1

@export var progress_container: Control
@export var available_potions: Array[ItemResource] = []

@export_category("Water")
@export var water_mesh: MeshInstance3D
@export var default_water_color := Color.WHITE #water_mesh.material_override.get_shader_parameter("water_color")

@onready var overheat_timer: Overheat = $OverheatTimer
@onready var hurt_box: HurtBox = $HurtBox
@onready var zelda_fire: Node3D = $ZeldaFire
@onready var brewing: AudioStreamPlayer = $Brewing
@onready var drop: AudioStreamPlayer = $Drop
@onready var take: AudioStreamPlayer = $Take
@onready var mix_action: ProcessActionCircular = $ProcessActionCircular

var items: Array = []
var mixing_player: FPSPlayer = null

var finished := false
var required_time := 0.0:
	set(v):
		required_time = max(v, 1.0)
		progress.max_value = required_time

var time := 0.0:
	set(v):
		time = clamp(v, 0, required_time)
		progress.value = time
		
var mixing := false:
	set(v):
		mixing = v
		brewing.volume_db = -15 if v else -25
		if overheat_timer.overheating:
			if mixing:
				_overload_stop_anim()
			else:
				_overload_start_anim()
		if not mixing:
			_unfreeze_mixing_player()

var health_bar: ProgressBar
var destroyed := false
var overload_tween: Tween
var overload_base_position := Vector2.ZERO
var overload_move_offset := 3.0

func _overload_start_anim():
	if not progress_container:
		return

	if overload_tween and overload_tween.is_running():
		overload_tween.kill()

	var start_pos: Vector2 = overload_base_position
	var offset: Vector2 = Vector2(overload_move_offset, 0.0)
	overload_tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	overload_tween.tween_property(progress_container, "position", start_pos + offset, 0.05).set_delay(1.0)
	overload_tween.tween_property(progress_container, "position", start_pos - offset, 0.1)
	overload_tween.tween_property(progress_container, "position", start_pos + offset, 0.1)
	overload_tween.tween_property(progress_container, "position", start_pos, 0.05)

func _overload_stop_anim():
	if overload_tween and overload_tween.is_running():
		overload_tween.kill()

	progress_container.position = overload_base_position

func _ready() -> void:
	super()
	zelda_fire.show()
	reset()
	
	mix_action.circle_finished.connect(func():
		time += mix_progress_per_circle
		overheat_timer.reduce_overheat(overheat_decrease_per_circle)
	)
	overheat_timer.overheated.connect(_failed_potion)
	overheat_timer.overheating_changed.connect(func(value: bool):
		if value:
			_overload_start_anim()
		else:
			_overload_stop_anim()
	)

	hurt_box.health_changed.connect(func():
		if health_bar:
			health_bar.value = hurt_box.health
	)
	hurt_box.died.connect(func(): died.emit())
	died.connect(func():
		destroyed = true
		Events.cauldron_destroyed.emit()
	)
	
func setup_health_bar(bar: ProgressBar):
	health_bar = bar
	health_bar.value = hurt_box.max_health
	health_bar.max_value = hurt_box.max_health

func interact(actor: FPSPlayer) -> void:
	var player := actor as FPSPlayer
	
	if player.has_item():
		if player.is_holding_potion():
			return

		var item = player.release_item()
		_add_item(item.type)
		required_time = mix_time_per_item * items.size()
		finished = false
		overheat_timer.reset()
		_check_mixing_items()
		Events.cauldron_used.emit()
		drop.play()
	elif not items.is_empty() and _is_only_potions():
		var item = items.pop_back()
		_find_item_for(item).queue_free()
		
		player.pickup_item(ItemResource.get_resource(item))
		take.play()
		
		if items.is_empty():
			reset()
			_reset_water()

func action(actor: FPSPlayer) -> void:
	if items.is_empty():
		return
	if mixing_player and mixing_player != actor:
		return
	if mixing:
		return

	mixing_player = actor
	mixing_player.begin_action_lock(self)
	mixing = true
	sprite.hide()

	if mix_action:
		mix_action.start(actor)

func action_released(actor: FPSPlayer) -> void:
	if actor != mixing_player:
		return
	if mix_action:
		mix_action.action_released()

func cancel_action(actor: FPSPlayer) -> void:
	if actor != mixing_player:
		return
	mixing = false

func _clear_items():
	for child in item_container.get_children():
		child.queue_free()
	items.clear()
	sprite.texture = null

func _add_item(item: ItemResource.Type):
	#var child = _find_item_for(item)
	#if not child:
	_create_item_for(item)
	
	#child.count += 1
	items.append(item)
	sprite.texture = mix_icon if not items.is_empty() else null

func _create_item_for(item: ItemResource.Type):
	var new_item = item_scene.instantiate()
	new_item.item = ItemResource.get_resource(item)
	item_container.add_child(new_item)
	return new_item

func _find_item_for(item: ItemResource.Type):
	for child in item_container.get_children():
		if child.item.type == item:
			return child
	return null

func _process(delta: float) -> void:
	if items.is_empty():
		brewing.stop()
		progress.hide()
		return
	
	progress.show()
	if finished:
		overheat_timer.start_if_stopped()
	overheat_timer.update_overheat(delta)
	
	if not brewing.playing:
		brewing.play()
	
	if not is_instance_valid(mixing_player) and mixing:
		mixing = false

	if mixing and mix_action:
		if not mix_action.running:
			mix_action.start(mixing_player)
		
		mix_action.update(delta)

	time += delta
	if time >= required_time and not finished:
		_on_finished()

func _on_finished():
	if finished: return
	finished = true
	#mixing = false
	
	_check_final_mix()
	if items.is_empty(): return

	overheat_timer.start_if_stopped()

func _is_only_potions() -> bool:
	if items.is_empty(): return false
	
	for i in items:
		if not ItemResource.is_potion(i):
			return false
	return true

func _unfreeze_mixing_player() -> void:
	if mixing_player:
		mixing_player.end_action_lock(self)
		mixing_player = null
	if mix_action and mix_action.running:
		mix_action.cancel()

func _check_mixing_items() -> void:
	var potion = ItemResource.find_potential_recipe(items, false, available_potions)
	if potion == null:
		_failed_potion()
		return

func _check_final_mix():
	var potion = ItemResource.find_potential_recipe(items, true, available_potions)
	if potion:
		_clear_items()
		for i in range(potion_size):
			_add_item(potion)
		success_anim.play("init")
		Events.cauldron_potion_created.emit()
		mixing = false

		var potion_resource: PotionResource = ItemResource.get_resource(potion) as PotionResource
		var color: Color = Color.WHITE
		if potion_resource:
			color = potion_resource.color
		water_mesh.material_override.set_shader_parameter("water_color", color * 1.5)

func _failed_potion():
	if _is_only_potions():
		var potion = items[0]
		var node = Potion.spawn_effect(potion, global_position)
		get_tree().current_scene.add_child(node)
	
	_clear_items()
	_reset_values()
	failure_anim.play("hit")
	_reset_water()

func _reset_water():
	water_mesh.material_override.set_shader_parameter("water_color", default_water_color)

func reset(_restore = false):
	_clear_items()
	_reset_values()
	_unfreeze_mixing_player()
	_reset_water()

func _reset_values():
	required_time = 0.0
	time = 0.0
	overheat_timer.reset()
	mixing = false
	finished = false
