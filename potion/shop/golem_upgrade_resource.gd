class_name GolemUpgradeResource
extends UpgradeResource

enum Type {
	CONSUMPTION,
	DAMAGE,
	RANGE,
	ATTACK_SPEED,
	
	PROJECTILE_COUNT
}

@export var stat := Type.CONSUMPTION
@export var values: Array[float] = []
@export var price_increase := 1.5
