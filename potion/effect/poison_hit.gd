extends Node3D

@onready var lifetime: Timer = $Lifetime
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	lifetime.timeout.connect(func(): animation_player.play("stop"))
