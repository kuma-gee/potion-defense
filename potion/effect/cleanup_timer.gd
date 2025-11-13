class_name CleanupTimer
extends Timer

@export var status_area: PotionHitArea
@export var nodes: Array[Node] = []

func _ready() -> void:
	one_shot = true
	if status_area:
		status_area.finished.connect(func(): _cleanup())
	else:
		start()
	
	timeout.connect(func(): get_parent().queue_free())

func _cleanup():
	for p in nodes:
		if p is GPUParticles3D:
			(p as GPUParticles3D).emitting = false
		else:
			p.hide()
	start()
