class_name HitBox
extends Area3D

@export var element := ElementalArea.Element.NONE
@export var damage := 1.0
@export var force := 0
@export var hit_sound: RandomizedLoopSfx

func _ready() -> void:
	if has_element():
		collision_mask = collision_mask | ElementalArea.LAYER

func has_element() -> bool:
	return element != ElementalArea.Element.NONE

func apply_potion(potion: PotionResource, multiplier: float = 1.0):
	element = potion.element
	damage = potion.damage * multiplier

# !!! This cannot be called immediately in _ready
# !!! Add a short delay before
func hit():
	for b in get_overlapping_areas():
		if b is ElementalArea and has_element():
			b.received_element(element)
		elif b is HurtBox:
			var dir = global_position.direction_to(b.global_position)
			b.hit(damage, dir * force, element)
			if hit_sound:
				hit_sound.play_randomized()

func can_hit():
	for b in get_overlapping_areas():
		if b is HurtBox:
			return true
	return false
