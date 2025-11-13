class_name PotionHitArea
extends Area3D

signal finished()

@export var lifetime: float = 0.1
@export var effect: StatusEffect
@export var tick_interval: float = 0.0

var is_finished := false
var tick_timer: float = 0.0

func _ready() -> void:
	area_entered.connect(func(a): _apply_status_effect_to_target(a))

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

			for area in get_overlapping_areas():
				_apply_status_effect_to_target(area)

func _apply_status_effect_to_target(target: HurtBox) -> void:
	if not target or not target.status_manager:
		return
	
	if effect:
		target.status_manager.apply_effect(effect)
