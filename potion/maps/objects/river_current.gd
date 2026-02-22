extends Obstacle

@onready var collision_shape_3d: CollisionShape3D = $StaticBody3D/CollisionShape3D
@onready var timer: Timer = $Timer

func _ready() -> void:
	deactivate()
	timer.timeout.connect(func():
		deactivate()
		finished.emit()
	)
	
func activate():
	super()
	collision_shape_3d.disabled = false
	show()
	timer.start()

func deactivate():
	collision_shape_3d.disabled = true
	hide()
