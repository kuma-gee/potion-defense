class_name Golem
extends Node3D

@export var range_mesh: Node3D

var golem: GolemResource
var potion: PotionResource = null

func _ready() -> void:
	if range_mesh:
		range_mesh.hide()

func on_hover():
	if range_mesh:
		range_mesh.visible = potion != null

func on_unhover():
	if range_mesh:
		range_mesh.hide()

func get_consumption(delta: float):
	if not is_active(): return 0.0
	return golem.consumption * delta * Events.get_golem_upgrade_value(golem, GolemUpgradeResource.Type.CONSUMPTION)

func is_active():
	return true

func process(_delta: float):
	pass

func set_potion_type(type: PotionResource) -> void:
	potion = type
