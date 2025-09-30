extends Area3D

func activate() -> void:
	for b in get_overlapping_bodies():
		if b.has_method("levitate"):
			b.levitate()

	queue_free()
