class_name WandAbility
extends Node

signal start_charge()
signal finish_charge()

@export var player: FPSPlayer
var wand: WandResource

var is_active: bool = false
var time_remaining: float = 0.0
var cooldown_remaining: float = 0.0
var charging_timer: float = 0.0

func is_on_cooldown() -> bool:
	return cooldown_remaining > 0.0

func activate() -> void:
	if wand == null:
		print("No wand ability set")
		return
	
	if is_active:
		print("Wand ability already active")
		return

	if is_on_cooldown():
		print("Cannot activate wand ability, still on cooldown: %.1fs remaining" % cooldown_remaining)
		return
	
	if wand.charge_time > 0.0:
		charging_timer = wand.charge_time
		start_charge.emit()
		print("Charging wand ability for %.1fs" % wand.charge_time)
		return
	
	if charging_timer > 0.0:
		print("Still charging at %s" % charging_timer)
		return
	
	_do_activate()

func _do_activate():
	charging_timer = 0.0
	time_remaining = wand.duration
	if time_remaining > 0.0:
		is_active = true
	
	# Shield has a special cooldown way
	if wand.ability_type != WandResource.AbilityType.SHIELD:
		cooldown_remaining = wand.cooldown

	_on_activate()

func deactivate() -> void:
	charging_timer = 0.0
	finish_charge.emit()
	_on_deactivate()

func start_cooldown() -> void:
	cooldown_remaining = wand.cooldown

func _process(delta: float) -> void:
	if charging_timer > 0.0:
		charging_timer -= delta
		if charging_timer <= 0.0:
			finish_charge.emit()
			_do_activate()
		return

	if cooldown_remaining > 0.0:
		cooldown_remaining = max(0.0, cooldown_remaining - delta)

	if is_active:
		time_remaining -= delta
		_on_process(delta)
		
		if time_remaining <= 0.0:
			_on_active_timeout()

func _on_active_timeout():
	is_active = false
	time_remaining = 0.0
	charging_timer = 0.0

func reset():
	_on_active_timeout()
	cooldown_remaining = 0.0

func _on_activate() -> void:
	match wand.ability_type:
		WandResource.AbilityType.TELEPORT_RETURN:
			var map = player.get_tree().get_first_node_in_group(Map.GROUP) as Map
			player.global_transform.origin = map.get_spawn_position(player.player_num)
		WandResource.AbilityType.SHIELD:
			player.activate_shield()
		

func _on_deactivate() -> void:
	match wand.ability_type:
		WandResource.AbilityType.SHIELD:
			player.deactivate_shield()

func _on_process(_delta: float) -> void:
	pass

func get_processing_speed() -> float:
	if is_active and wand.ability_type == WandResource.AbilityType.PROCESSING_SPEED:
		return wand.effect_value
	return 1.0
