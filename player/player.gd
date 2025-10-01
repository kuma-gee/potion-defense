class_name Player
extends CharacterBody3D

signal died()

var health := 5:
	set(v):
		health = v
		print("Player Health: %s" % v)
		if is_dead():
			died.emit()

func _ready() -> void:
	died.connect(_on_died)

func _on_died() -> void:
	queue_free()

func is_dead():
	return health <= 0

func is_grounded():
	return is_on_floor()

func hit(_from_pos: Vector3):
	if is_dead():
		return

	health -= 1
