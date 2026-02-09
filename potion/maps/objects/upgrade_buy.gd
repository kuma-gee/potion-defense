class_name UpgradeBuy
extends RayInteractable

const ICON = preload("uid://b26o7ob7o2den")

signal upgrade_selected(upgrade: UpgradeResource)

@export var name_label: Label
@export var description_label: Label
@onready var icon: Sprite3D = $Icon

var upgrade: UpgradeResource
var golem: GolemResource:
	set(v):
		golem = v
		update_display()

func _ready() -> void:
	super()
	Events.upgrade_unlocked.connect(func(): update_display())

	if upgrade is GolemResource:
		var node = upgrade.scene.instantiate()
		add_child(node)
	else:
		var ico = upgrade.icon if upgrade.icon else ICON
		var mat = icon.material_override as ShaderMaterial
		mat.set_shader_parameter("sprite_texture", ico)

	update_display()

func update_display():
	var final_price = upgrade.price

	if upgrade is GolemResource:
		final_price = int(upgrade.price * pow(upgrade.price_increase, Events.get_golem_count(upgrade)))
	elif upgrade is GolemUpgradeResource:
		var count = Events.get_golem_upgrade_count(golem, upgrade)
		final_price = int(upgrade.price * pow(upgrade.price_increase, count))

	name_label.text = "%s (%s)" % [upgrade.name, final_price]
	description_label.text = upgrade.description

func interact(_a: FPSPlayer):
	if not upgrade: return
	upgrade_selected.emit(upgrade)
