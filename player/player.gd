class_name Player
extends CharacterBody3D

const GROUP = "player"

signal died()

@onready var player_movement: PlayerMovement = $PlayerMovement
@onready var player_animation: AnimationTree = $PlayerAnimation
@onready var dodge_area: DodgeArea = $DodgeArea

@export var dodge_time_scale: float = 0.5
@export var dodge_time_duration: float = 0.3

var dodging := false
var health := 5:
	set(v):
		health = v
		print("Player Health: %s" % v)
		if is_dead():
			died.emit()

func _ready() -> void:
	add_to_group(GROUP)
	died.connect(_on_died)
	dodge_area.dodged.connect(_on_dodged)

func _on_died() -> void:
	queue_free()
	
func _on_dodged():
	dodging = true
	Engine.time_scale = dodge_time_scale
	await get_tree().create_timer(dodge_time_duration, false).timeout
	Engine.time_scale = 1.0
	dodging = false

func is_dead():
	return health <= 0

func is_grounded():
	return is_on_floor()

func hit(from_pos: Vector3, force: float = 10.0):
	if is_dead() or dodging:
		return

	health -= 1

	var knockback = _get_knockback_direction(from_pos) * force
	player_movement.knockback = knockback
	player_animation.hit()

func _get_knockback_direction(from_pos: Vector3) -> Vector3:
	var dir = (global_position - from_pos).normalized()
	dir.y = 0
	return dir

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("sprint"):
		dodge_area.dodge()
