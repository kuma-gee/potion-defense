class_name Soul
extends Area3D

@export var amount := 1
@export var sfx: AudioStream

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is FPSPlayer:
		Events.collect_soul(amount)
		AudioManager.play_randomized_sfx(sfx, -10, 1, 1.2)
		queue_free()  # Remove the soul from the scene
