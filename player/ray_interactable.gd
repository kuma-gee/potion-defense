class_name RayInteractable
extends Area3D

const LAYER = 1 << 15

signal hovered(actor)
signal unhovered(actor)
signal interacted(actor)
signal released(actor)

@export var label: Label3D
@export var sprite: Sprite3D

func _ready() -> void:
	collision_layer = LAYER
	
	if label:
		label.hide()
	if sprite:
		sprite.hide()

func hover(actor: FPSPlayer):
	if label:
		label.show()
	if sprite:
		sprite.show()
	hovered.emit(actor)

func unhover(actor: FPSPlayer):
	if label:
		label.hide()
	if sprite:
		sprite.hide()
	unhovered.emit(actor)

func interact(actor: FPSPlayer):
	if label:
		label.hide()
	if sprite:
		sprite.hide()
	interacted.emit(actor)

func release(actor: FPSPlayer):
	released.emit(actor)
	
func action(actor: FPSPlayer):
	pass

func action_released(actor: FPSPlayer):
	pass
