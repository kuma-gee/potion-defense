extends Node3D

@export var area_effect: PotionHitArea
@export var elemental: ElementalArea
@export var fire_vfx: GPUParticles3D
@export var cleanup_timer: Timer
@export var slime_mesh: MeshInstance3D

@export var burn_dmg: StatusEffect
@export var burn_lifetime: float = 3.0

var burning := false:
	set(v):
		burning = v
		fire_vfx.emitting = burning
		slime_mesh.visible = not burning

func _ready() -> void:
	area_effect.finished.connect(func(): cleanup_timer.start())
	cleanup_timer.timeout.connect(func(): queue_free())

	elemental.received.connect(func(element):
		if element == ElementalArea.Element.FIRE and not burning:
			burning = true
			area_effect.effect = burn_dmg
			area_effect.start_lifetime(burn_lifetime)
	)
