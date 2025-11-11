class_name RayInteractable
extends Area3D

signal hovered(actor)
signal unhovered(actor)
signal interacted(actor)
signal released(actor)

@export var label: Label3D
@export var sprite: Sprite3D

func _ready() -> void:
	if label:
		label.hide()
	if sprite:
		sprite.hide()

func hover(actor):
	hovered.emit(actor)
	if label:
		label.show()
	if sprite:
		sprite.show()

func unhover(actor):
	unhovered.emit(actor)
	if label:
		label.hide()
	if sprite:
		sprite.hide()

func interact(actor):
	if label:
		label.hide()
	if sprite:
		sprite.hide()
	interacted.emit(actor)

func release(actor):
	released.emit(actor)
	
