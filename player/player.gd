class_name Player
extends CharacterBody3D

signal died()

@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var health := 5:
	set(v):
		health = v
		print("Player Health: %s" % v)
		if health <= 0:
			died.emit()

func _ready() -> void:
	died.connect(_on_died)

func _on_died() -> void:
	queue_free()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

func is_dead():
	return false

func is_grounded():
	return is_on_floor()

func hit(_from_pos: Vector3):
	health -= 1
