class_name RayInteractable
extends Area3D

signal hovered(actor)
signal unhovered(actor)
signal interacted(actor)
signal released(actor)

@export var label: Label3D

func _ready() -> void:
	label.hide()

func hover(actor):
	hovered.emit(actor)
	label.show()

func unhover(actor):
	unhovered.emit(actor)
	label.hide()

func interact(actor):
	label.hide()
	interacted.emit(actor)

func release(actor):
	released.emit(actor)
	
