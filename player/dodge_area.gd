class_name DodgeArea
extends Area3D

signal dodged()

func dodge():
	for area in get_overlapping_areas():
		if area is HitBox and area.is_dodgeable:
			dodged.emit()
			return
