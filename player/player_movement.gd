class_name PlayerMovement
extends Node

@export var body: Node3D
@onready var player: Player = get_parent()

var knockback: Vector3
var was_sprinting: bool = false
var sprint_boost_timer: float = 0.0

func _physics_process(delta):
	if player.is_dead():
		return
