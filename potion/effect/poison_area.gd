extends Node3D

@onready var puff_clouds_2: GPUParticles3D = $puff_clouds2
@onready var poison: PotionHitArea = $Poison

func _ready() -> void:
	puff_clouds_2.lifetime = poison.lifetime
	puff_clouds_2.emitting = true
	poison.finished.connect(func():
		await get_tree().create_timer(0.5).timeout # in case particles are still visible
		queue_free()
	)
