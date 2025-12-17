class_name UpgradeBuy
extends RayInteractable

@export var name_label: Label
@export var description_label: Label
@onready var icon: Sprite3D = $Icon

var upgrade: UpgradeResource

func _ready() -> void:
	super()
	name_label.text = "%s (%s)" % [upgrade.name, upgrade.price]
	description_label.text = upgrade.description

	if upgrade.icon:
		icon.texture = upgrade.icon

func interact(_a: FPSPlayer):
	if not upgrade: return

	if Events.buy_upgrade(upgrade):
		queue_free()
