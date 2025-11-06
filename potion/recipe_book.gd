class_name RecipeBook
extends RayInteractable

@export var container: Control

func _ready() -> void:
	super ()
	label.text = "Open Recipe Book"
	interacted.connect(func(_a: FPSPlayer): container.grab_focus())
