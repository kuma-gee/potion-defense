class_name ProcessingSpeedAbility
extends WandAbility

var speed_multiplier: float = 1.0

func _init(p_player: FPSPlayer, p_wand: WandResource) -> void:
	super(p_player, p_wand)
	speed_multiplier = wand.effect_value
	is_active = true
	print("Processing Speed ability equipped! Passive multiplier: %.1fx" % speed_multiplier)

func get_speed_multiplier() -> float:
	return speed_multiplier
