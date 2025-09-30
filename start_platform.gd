class_name StartPlatform
extends Node3D

signal pressed()

@export var area: Area3D

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not body is Player or not visible: return

	hide()
	pressed.emit()

func reset():
	show()
