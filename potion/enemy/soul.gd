class_name Soul
extends Area3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is FPSPlayer:
		var player: FPSPlayer = body
		player.soul_collected.emit()
		queue_free()  # Remove the soul from the scene
