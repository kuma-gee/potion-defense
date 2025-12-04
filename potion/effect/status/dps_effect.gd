class_name DpsEffect
extends StatusEffect

@export var effect_name := "fire"
@export var damage_per_tick := 1

func get_effect_type() -> String:
	return "dps-%s" % effect_name

func on_tick() -> void:
	target.damage(damage_per_tick, element)
