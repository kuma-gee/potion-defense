class_name RecipeBook
extends RayInteractable

@export var closed_book: Node3D
@export var open_book: Node3D
@export var enter_area: Area3D

var entered := false:
	set(v):
		entered = v
		closed_book.visible = not v
		open_book.visible = v

func _ready() -> void:
	super()
	entered = false
	enter_area.body_entered.connect(func(_a): entered = true)
	enter_area.body_exited.connect(func(_a): entered = has_overlapping_bodies())
