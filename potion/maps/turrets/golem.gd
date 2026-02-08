class_name Golem
extends Node3D

var golem: GolemResource
var potion: PotionResource = null

func get_consumption(_delta: float):
	return 0.0

func process(_delta: float):
	pass

func set_potion_type(type: PotionResource) -> void:
	potion = type
