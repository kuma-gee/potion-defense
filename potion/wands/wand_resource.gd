class_name WandResource
extends Resource

enum AbilityType {
	PROCESSING_SPEED,
	TELEPORT,
	DAMAGE_BOOST,
	SHIELD,
	SLOW_TIME
}

@export var name: String = ""
@export var description: String = ""
@export var ability_type: AbilityType = AbilityType.PROCESSING_SPEED
@export var cooldown: float = 5.0
@export var duration: float = 3.0
@export var effect_value: float = 1.0
