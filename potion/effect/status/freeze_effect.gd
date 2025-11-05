class_name FreezeEffect
extends StatusEffect

@export var slow_multiplier: float = 0.3

var original_speed: float = 0.0

func _init(p_duration: float = 3.0, p_slow_multiplier: float = 0.3) -> void:
	super._init(p_duration, 0.5)
	slow_multiplier = p_slow_multiplier

func get_effect_type() -> String:
	return "freeze"

func on_apply() -> void:
	print("%s is frozen!" % target.name)
	
	# Store original speed and reduce it
	if "speed" in target:
		original_speed = target.speed
		target.speed *= slow_multiplier

func on_remove() -> void:
	print("%s is no longer frozen" % target.name)
	
	# Restore original speed
	if "speed" in target and original_speed > 0:
		target.speed = original_speed
