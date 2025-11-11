class_name HurtBox
extends Area3D

signal died()
signal health_changed()
signal damaged(dmg)
signal knockbacked(force)

@export var status_manager: StatusEffectManager
@export var max_health := 10
@onready var health := max_health:
	set(v):
		health = clamp(v, 0, max_health)
		health_changed.emit()
		
		if health <= 0:
			monitorable = false
			died.emit()

func set_max_health(new_max_health: int):
	max_health = new_max_health
	health = new_max_health
	health_changed.emit()

func hit(dmg: int, knockback = Vector3.ZERO):
	health -= dmg
	damaged.emit(dmg)
	if knockback:
		knockbacked.emit(knockback)

func is_dead():
	return health <= 0
