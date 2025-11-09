class_name PotionHitArea
extends Area3D

signal finished()

@export var lifetime: float = 0.1
@export var effect: StatusEffect
@export var tick_interval: float = 0.0

var is_finished := false
var tick_timer: float = 0.0

func _ready() -> void:
	#for body in get_overlapping_bodies():
		#_apply_status_effect_to_target(body)
	body_entered.connect(func(a): _apply_status_effect_to_target(a))

	if lifetime > 0:
		get_tree().create_timer(lifetime).timeout.connect(func():
			is_finished = true
			finished.emit()
		)

func _process(delta: float) -> void:
	if tick_interval > 0 and not is_finished:
		tick_timer += delta
		if tick_timer >= tick_interval:
			tick_timer -= tick_interval

			for body in get_overlapping_bodies():
				_apply_status_effect_to_target(body)
	
func _apply_status_effect_to_target(target: Node) -> void:
	if not target:
		return
	
	var effect_manager: StatusEffectManager = null
	
	if target.has_node("StatusEffectManager"):
		effect_manager = target.get_node("StatusEffectManager")
	else:
		for child in target.get_children():
			if child is StatusEffectManager:
				effect_manager = child
				break
	
	if not effect_manager:
		return
	
	if effect:
		effect_manager.apply_effect(effect)
