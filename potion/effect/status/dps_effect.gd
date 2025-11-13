class_name DpsEffect
extends StatusEffect

@export var effect_name := "fire"
@export var damage_per_tick: float = 1.0

func get_effect_type() -> String:
	return "dps-%s" % effect_name

func on_tick() -> void:
	target.damage(damage_per_tick)