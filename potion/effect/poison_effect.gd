class_name PoisonEffect
extends StatusEffect

@export var damage_per_tick: float = 0.5

func _init(p_duration: float = 8.0, p_damage_per_tick: float = 0.5) -> void:
	super._init(p_duration, 1.0)
	damage_per_tick = p_damage_per_tick

func get_effect_type() -> String:
	return "poison"

func on_apply() -> void:
	print("%s is poisoned!" % target.name)

func on_tick() -> void:
	if target and target.has_method("take_damage"):
		target.take_damage(damage_per_tick)
	elif target and "health" in target:
		target.health -= damage_per_tick
	print("%s takes %s poison damage" % [target.name, damage_per_tick])

func on_remove() -> void:
	print("%s is no longer poisoned" % target.name)
