extends Obstacle

@onready var collision_shape_3d: CollisionShape3D = $StaticBody3D/CollisionShape3D
@onready var timer: Timer = $Timer
@onready var interactable_detector: Area3D = $InteractableDetector

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
	
	for area in interactable_detector.get_overlapping_areas():
		if area is PlaceableSlot:
			area.item = null

func deactivate():
	super()
	collision_shape_3d.disabled = true
	hide()
