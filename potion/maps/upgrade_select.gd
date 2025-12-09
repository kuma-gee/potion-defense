class_name UpgradeSelect
extends RayInteractable

@onready var icon: Sprite3D = $Icon
@onready var label_3d: Label3D = $Label3D

var upgrade: UpgradeResource

func _ready() -> void:
	super()
	
	label_3d.text = upgrade.name
	if upgrade.icon:
		icon.texture = upgrade.icon

func interact(actor: FPSPlayer):
	if not upgrade: return

	var player = actor as FPSPlayer
	if player:
		if upgrade is WandResource:
			player.equip_wand(upgrade as WandResource)
		elif upgrade is EquipmentResource:
			player.equip_equipment(upgrade as EquipmentResource)
