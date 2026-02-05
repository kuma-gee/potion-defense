class_name EquipmentResource
extends UpgradeResource

enum Type {
	SPEED_BOOTS,
	IMMUNITY_CLOAK,
	GATHERING_GLOVES,
}

@export var equipment_type := Type.SPEED_BOOTS
@export var stat_value: float = 1.0
