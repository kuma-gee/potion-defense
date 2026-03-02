extends Obstacle

@export var water_start_particles: GPUParticles3D
@onready var collision_shape_3d: CollisionShape3D = $StaticBody3D/CollisionShape3D
@onready var timer: Timer = $Timer
@onready var interactable_detector: Area3D = $InteractableDetector
@onready var activation_timer: Timer = $ActivationTimer

func _ready() -> void:
	water_start_particles.emitting = false
	deactivate()
	
	timer.timeout.connect(func():
		deactivate()
		finished.emit()
	)
	activation_timer.timeout.connect(func():
		water_start_particles.emitting = false
		collision_shape_3d.disabled = false
		show()
		timer.start()
		
		for area in interactable_detector.get_overlapping_areas():
			if area is PlaceableSlot and area.has_item():
				area.item = null
			elif area is ProcessingItem and area.item != null:
				area.reset()
	)
	
func activate():
	super()
	water_start_particles.emitting = true
	activation_timer.start()

func deactivate():
	super()
	collision_shape_3d.disabled = true
	hide()
