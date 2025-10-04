class_name Wisp
extends CharacterBody3D

@onready var detect_area: Area3D = $CollisionShape3D/DetectArea
@onready var blue_beam_impact: PlayParticleSystems = $BlueBeamImpact
@onready var drifting: Drifting = $Drifting
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var hide_wisp: ParticleCallback = $BlueBeamImpact/HideWisp
@onready var cleanup_timer: Timer = $CleanupTimer

func _ready() -> void:
	detect_area.body_entered.connect(func(_x):
		blue_beam_impact.play()
		drifting.process_mode = Node.PROCESS_MODE_DISABLED
		cleanup_timer.start()
	)
	hide_wisp.executed.connect(func(): collision_shape_3d.hide())
	cleanup_timer.timeout.connect(func(): queue_free())
