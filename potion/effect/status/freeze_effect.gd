class_name FreezeEffect
extends StatusEffect

@export var effect_name := "ice"
@export var slow_multiplier: float = 0.3

func get_effect_type() -> String:
	return "slow-%s" % effect_name

func on_apply() -> void:
	target.slow(get_effect_type(), slow_multiplier)

func on_remove() -> void:
	target.slow(get_effect_type(), 1.0)
