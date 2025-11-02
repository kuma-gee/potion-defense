class_name HurtBox
extends Area3D

signal died()
signal health_changed()
signal knockbacked(force)

@export var max_health := 10
@onready var health := max_health:
	set(v):
		health = clamp(v, 0, max_health)
		health_changed.emit()
		
		if health <= 0:
			died.emit()

func hit(dmg: int, knockback = Vector3.ZERO):
	health -= dmg
	
	if knockback:
		knockbacked.emit(knockback)

func is_dead():
	return health <= 0
