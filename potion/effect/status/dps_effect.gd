class_name DpsEffect
extends StatusEffect

@export var damage_per_tick: float = 1.0

func get_effect_type() -> String:
	return "burn"

func on_apply() -> void:
	print("%s is now burning!" % target.name)

func on_tick() -> void:
	if target and target.has_method("take_damage"):
		target.take_damage(damage_per_tick)
	elif target and "health" in target:
		target.health -= damage_per_tick
	print("%s takes %s burn damage" % [target.name, damage_per_tick])

func on_remove() -> void:
	print("%s is no longer burning" % target.name)
