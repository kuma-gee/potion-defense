class_name FreezeEffect
extends StatusEffect

@export var slow_multiplier: float = 0.3

func get_effect_type() -> String:
	return "slow"

func on_apply() -> void:
	target.speed = target.get_original_speed() * slow_multiplier

func on_remove() -> void:
	target.speed = target.get_original_speed()
