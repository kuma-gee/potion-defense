class_name GolemResource
extends UpgradeResource

enum Type {
	MELEE,
	AOE,
}

@export var type := Type.MELEE
@export var scene: PackedScene
@export var consumption := 1.0
@export var attack_speed := 5.0
