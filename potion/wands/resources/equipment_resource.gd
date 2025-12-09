class_name EquipmentResource
extends UpgradeResource

enum EquipmentType {
	BOOTS,
	CLOAK,
	RING,
	AMULET
}

enum StatType {
	SPEED,
	DEFENSE,
	HEALTH,
	DAMAGE
}

@export var equipment_type: EquipmentType = EquipmentType.BOOTS
@export var stat_type: StatType = StatType.SPEED
@export var stat_value: float = 1.0
