extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var blue_beam_impact: PlayParticleSystems = $BlueBeamImpact
@onready var frost: PotionHitArea = $Frost
@onready var cleanup_timer: Timer = $CleanupTimer

func _ready() -> void:
	animation_player.play("start")
	frost.finished.connect(func():
		animation_player.play("stop")
		cleanup_timer.start()
	)
	cleanup_timer.timeout.connect(func(): queue_free())
