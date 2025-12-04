class_name HitBox
extends Area3D

@export var element := ElementalArea.Element.NONE
@export var damage := 1
@export var force := 0

func _ready() -> void:
	if has_element():
		collision_mask = collision_mask | ElementalArea.LAYER

func has_element() -> bool:
	return element != ElementalArea.Element.NONE

func hit():
	for b in get_overlapping_areas():
		if b is ElementalArea and has_element():
			b.received_element(element)
		elif b is HurtBox:
			var dir = global_position.direction_to(b.global_position)
			b.hit(damage, dir * force, element)

func can_hit():
	for b in get_overlapping_areas():
		if b is HurtBox:
			return true
	return false
