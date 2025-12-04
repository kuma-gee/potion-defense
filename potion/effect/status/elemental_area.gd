class_name ElementalArea
extends Area3D

const LAYER = 1 << 10

enum Element {
	NONE,
	FIRE,
	ICE,
	LIGHTNING,
	POISON,
}

signal received(element: Element)

@export var element: Element = Element.NONE

func _ready() -> void:
	collision_layer = LAYER
	collision_mask = LAYER

	area_entered.connect(func(area):
		if area is ElementalArea and is_active():
			var elemental_area := area as ElementalArea
			elemental_area.received_element(element)
	)

func has_contact_with(elem: Element) -> bool:
	for area in get_overlapping_areas():
		if area is ElementalArea:
			var elemental_area := area as ElementalArea
			if elemental_area.element == elem:
				return true
	return false

func received_element(elem: Element) -> void:
	received.emit(elem)

func is_active():
	return true
