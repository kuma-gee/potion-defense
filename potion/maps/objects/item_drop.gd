class_name ItemDrop
extends Node

signal landed()

@export var visual: Node3D
@export var drop_height := 3.0
@export var drop_speed := 3.0

var is_landed := false

func start():
	visual.position.y = drop_height
	is_landed = false

func land():
	visual.position.y = 0
	is_landed = true
	landed.emit()

func process(delta: float) -> bool:
	if is_landed: return false
	
	if visual.position.y > 0.0:
		visual.position.y -= delta * drop_speed
	else:
		land()

	return true
