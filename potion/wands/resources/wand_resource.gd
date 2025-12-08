class_name WandResource
extends UpgradeResource

enum AbilityType {
	PROCESSING_SPEED,
	TELEPORT,
	DAMAGE_BOOST,
	SHIELD,
	SLOW_TIME
}

@export var ability_type: AbilityType = AbilityType.PROCESSING_SPEED
@export var cooldown: float = 5.0
@export var duration: float = 3.0
@export var effect_value: float = 1.0
