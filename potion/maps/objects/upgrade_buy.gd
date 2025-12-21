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
		var mat = icon.material_override as ShaderMaterial
		mat.set_shader_parameter("sprite_texture", upgrade.icon)

func interact(_a: FPSPlayer):
	if not upgrade: return

	if Events.buy_upgrade(upgrade):
		queue_free()
