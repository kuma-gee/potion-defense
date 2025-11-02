class_name ParalysisEffect
extends StatusEffect

var original_speed: float = 0.0
var was_attacking: bool = false

func _init(p_duration: float = 2.0) -> void:
	super._init(p_duration, 0.5)

func get_effect_type() -> String:
	return "paralysis"

func on_apply() -> void:
	print("%s is paralyzed!" % target.name)
	
	# Store and disable movement
	if "speed" in target:
		original_speed = target.speed
		target.speed = 0
	
	# Stop any ongoing attacks
	if "is_attacking" in target:
		was_attacking = target.is_attacking
		target.is_attacking = false

func on_remove() -> void:
	print("%s is no longer paralyzed" % target.name)
	
	# Restore movement
	if "speed" in target and original_speed > 0:
		target.speed = original_speed
