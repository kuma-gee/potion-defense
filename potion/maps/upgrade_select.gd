class_name UpgradeSelect
extends RayInteractable

signal upgrade_selected(upgrade: UpgradeResource)

@export var name_label: Label
@export var description_label: Label
@export var count_label: Label3D
@onready var icon: Sprite3D = $Icon

var upgrade: UpgradeResource

func _ready() -> void:
	super()
	Events.upgrade_unlocked.connect(_update_count)

	name_label.text = upgrade.name
	description_label.text = upgrade.description

	if upgrade is GolemResource:
		var node = upgrade.scene.instantiate()
		add_child(node)
		_update_count()
		icon.hide()
	elif upgrade.icon:
		var mat = icon.material_override as ShaderMaterial
		mat.set_shader_parameter("sprite_texture", upgrade.icon)
		count_label.hide()

func _update_count():
	count_label.text = "%dx" % Events.golem_counts.get(upgrade, 0)
	count_label.visible = Events.golem_counts.get(upgrade, 0) > 0

func interact(actor: FPSPlayer):
	if not upgrade: return
	upgrade_selected.emit(upgrade)

	# var player = actor as FPSPlayer
	# if player:
	# 	if upgrade is WandResource:
	# 		player.equip_wand(upgrade as WandResource)
	# 	elif upgrade is EquipmentResource:
	# 		player.equip_equipment(upgrade as EquipmentResource)
	# 	elif upgrade is GolemResource:
