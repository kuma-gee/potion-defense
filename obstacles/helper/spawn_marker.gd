class_name SpawnMarker
extends Node3D

signal activated()

@export var timer: Timer

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	activated.emit()
	queue_free() # TODO: fade out
