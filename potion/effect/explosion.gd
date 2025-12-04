extends Node3D

@onready var cleanup_timer: Timer = $CleanupTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("start")
	cleanup_timer.timeout.connect(func(): queue_free())
