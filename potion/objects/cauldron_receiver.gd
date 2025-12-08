class_name CauldronReceiver
extends RayInteractable

signal died()

@export var item_container: Control
@export var item_scene: PackedScene
@export var health_bar: Range

@export var progress: Range
@export var overheat_progress: Range
@export var mix_time_per_item := 4.0
@export var mixing_speed_increase := 2.0
@export var overheat_time := 6.0
@export var overheat_decrease := -1.0

@export var success_anim: AnimationPlayer
@export var failure_anim: AnimationPlayer

@onready var overheat_start_timer: Timer = $OverheatStartTimer
@onready var hurt_box: HurtBox = $HurtBox
@onready var zelda_fire: Node3D = $ZeldaFire

var items: Array = []
var mixing_player: FPSPlayer = null

var overheat := 0.0:
	set(v):
		overheat = v
		overheat_progress.value = v

var overheating := false:
	set(v):
		overheating = v
		overheat = 0.0
		if not overheating:
			overheat_start_timer.stop()

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
		if not mixing:
			_unfreeze_mixing_player()

var destroyed := false

func _ready() -> void:
	super()
	zelda_fire.show()
	_clear_items()
	_reset_values()
	
	overheat_progress.max_value = overheat_time
	health_bar.value = hurt_box.max_health
	health_bar.max_value = hurt_box.max_health
	hurt_box.health_changed.connect(func(): health_bar.value = hurt_box.health)
	hurt_box.died.connect(func():
		if Events.level == 0:
			hurt_box.health = 5
		else:
			died.emit()
	)
	died.connect(func(): destroyed = true)
	
	interacted.connect(func(a: Node): handle_interacted(a))
	released.connect(func(a: Node): handle_released(a))
	overheat_start_timer.timeout.connect(func(): overheating = true)

func handle_interacted(actor: Node) -> void:
	if not (actor is FPSPlayer): return
	
	var player := actor as FPSPlayer
	
	if player.has_item():
		var item = player.release_item()
		_add_item(item.type)
		required_time = mix_time_per_item * items.size()
		finished = false
		overheating = false
		_check_mixing_items()
		Events.cauldron_used.emit()
	elif not items.is_empty():
		if _is_only_potions():
			var item = items.pop_back()
			reset()
			player.pickup_item(ItemResource.get_resource(item))
		elif not mixing:
			mixing_player = player
			mixing = true
			if mixing_player:
				mixing_player.freeze_player()

func _clear_items():
	for child in item_container.get_children():
		child.queue_free()
	items.clear()

func _add_item(item: ItemResource.Type):
	#var child = _find_item_for(item)
	#if not child:
	_create_item_for(item)
	
	#child.count += 1
	items.append(item)

func _create_item_for(item: ItemResource.Type):
	var new_item = item_scene.instantiate()
	new_item.item = ItemResource.get_resource(item)
	item_container.add_child(new_item)
	return new_item

func _find_item_for(item: ItemResource.Type):
	for child in item_container.get_children():
		if child.type == item:
			return child
	return null

func handle_released(_actor: Node) -> void:
	if mixing:
		mixing = false

func _process(delta: float) -> void:
	if items.is_empty(): return
	
	if overheating:
		overheat += delta * (1.0 if not mixing else overheat_decrease)
		if overheat >= overheat_time:
			_failed_potion()
		elif overheat <= 0.0:
			overheating = false
			overheat = 0.0
	elif finished and overheat_start_timer.is_stopped():
		overheat_start_timer.start()
	
	time += delta * (1.0 if not mixing else mixing_speed_increase)
	if time >= required_time and not finished:
		_on_finished()

func _on_finished():
	if finished: return
	finished = true
	
	_check_final_mix()
	if items.is_empty(): return

	if overheat_start_timer.is_stopped() and not overheating:
		overheat_start_timer.start()

func _is_only_potions() -> bool:
	if items.is_empty(): return false
	
	for i in items:
		if not ItemResource.is_potion(i):
			return false
	return true

func _unfreeze_mixing_player() -> void:
	if mixing_player:
		mixing_player.unfreeze_player()
		mixing_player = null

func _check_mixing_items() -> void:
	var potion = ItemResource.find_potential_recipe(items)
	if potion == null:
		_failed_potion()
		return

func _check_final_mix():
	var potion = ItemResource.find_potential_recipe(items, true)
	if potion:
		_clear_items()
		_add_item(potion)
		success_anim.play("init")

func _failed_potion():
	if _is_only_potions():
		var potion = items[0]
		var node = Potion.spawn_effect(potion, global_position)
		get_tree().current_scene.add_child(node)
	
	_clear_items()
	_reset_values()
	failure_anim.play("hit")

func reset(_restore = false):
	_clear_items()
	_reset_values()
	_unfreeze_mixing_player()

func _reset_values():
	required_time = 0.0
	time = 0.0
	overheat = 0.0
	overheating = false
	mixing = false
	finished = false
