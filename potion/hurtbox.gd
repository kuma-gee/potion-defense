class_name HurtBox
extends Area3D

signal died()
signal health_changed()

@export var max_health := 10
@onready var health := max_health:
	set(v):
		health = clamp(v, 0, max_health)
		health_changed.emit()
		print("Changed health: %s" % health)
		
		if health <= 0:
			died.emit()

func hit(dmg: int):
	health -= dmg
