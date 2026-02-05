class_name WandResource
extends UpgradeResource

enum AbilityType {
	PROCESSING_SPEED,
	SHIELD,
	TELEPORT_RETURN,
}

@export var ability_type: AbilityType = AbilityType.PROCESSING_SPEED
@export var cooldown: float = 5.0
@export var duration: float = 3.0
@export var effect_value: float = 1.0
@export var charge_time := 1.0
@export var color := Color.WHITE
