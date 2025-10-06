extends State

@export var character: CharacterBody3D

func enter() -> void:
	character.queue_free()
