class_name Throwable
extends RigidBody3D

func throw(direction: Vector3, force: float) -> void:
	apply_central_impulse(direction.normalized() * force)
