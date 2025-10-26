class_name Throwable
extends RigidBody3D

@onready var hit_effect: HitEffect = $HitEffect

func _ready() -> void:
	hit_effect.hit.connect(func(): queue_free())
	body_entered.connect(func(_b):
		print(linear_velocity.length())
		if linear_velocity.length() > 1:
			hit_effect.on_hit()
	)

func throw(direction: Vector3, force: float) -> void:
	apply_central_impulse(direction.normalized() * force)
