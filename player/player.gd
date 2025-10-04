class_name Player
extends CharacterBody3D

const GROUP = "player"

signal died()

@onready var player_movement: PlayerMovement = $PlayerMovement
@onready var player_animation: AnimationTree = $PlayerAnimation

var health := 5:
	set(v):
		health = v
		print("Player Health: %s" % v)
		if is_dead():
			died.emit()

func _ready() -> void:
	add_to_group(GROUP)
	died.connect(_on_died)

func _on_died() -> void:
	queue_free()

func is_dead():
	return health <= 0

func is_grounded():
	return is_on_floor()

func hit(from_pos: Vector3, force: float = 10.0):
	if is_dead():
		return

	health -= 1

	var knockback = _get_knockback_direction(from_pos) * force
	player_movement.knockback = knockback
	player_animation.hit()

func _get_knockback_direction(from_pos: Vector3) -> Vector3:
	var dir = (global_position - from_pos).normalized()
	dir.y = 0
	return dir
