class_name Soul
extends Area3D

@export var amount := 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is FPSPlayer:
		Events.collect_soul(amount)
		queue_free()  # Remove the soul from the scene
