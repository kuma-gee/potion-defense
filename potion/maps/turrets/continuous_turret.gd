class_name ContinuousTurret
extends PotionTurret

@export var consumption := 2.0
@export var area: PotionHitArea
@export var visual: Node3D

func get_consumption(delta):
	return consumption * delta
	
func activate():
	area.enable()
	visual.show()

func deactivate():
	area.disable()
	visual.hide()
