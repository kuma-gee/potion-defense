class_name GolemResource
extends UpgradeResource

enum Type {
	MELEE,
	AREA,
	RANGE,
}

@export var scene: PackedScene
@export var consumption := 1.0
@export var attack_speed := 5.0
@export var upgrades: Array[GolemUpgradeResource] = []
@export var price_increase := 1.7

# Check: might be removable, try not to use
@export var type := Type.MELEE
