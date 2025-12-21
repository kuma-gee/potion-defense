class_name UpgradeSelect
extends RayInteractable

@export var name_label: Label
@export var description_label: Label
@onready var icon: Sprite3D = $Icon

var upgrade: UpgradeResource

func _ready() -> void:
	super()
	name_label.text = upgrade.name
	description_label.text = upgrade.description

	if upgrade.icon:
		var mat = icon.material_override as ShaderMaterial
		mat.set_shader_parameter("sprite_texture", upgrade.icon)

func interact(actor: FPSPlayer):
	if not upgrade: return

	var player = actor as FPSPlayer
	if player:
		if upgrade is WandResource:
			player.equip_wand(upgrade as WandResource)
		elif upgrade is EquipmentResource:
			player.equip_equipment(upgrade as EquipmentResource)
